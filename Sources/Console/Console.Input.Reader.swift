#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)

    import Byte_Primitive
    import Standard_Library_Extensions
    import Terminal_Input_Primitives
    import Kernel

    import Kernel_Terminal

    extension Console.Input {
        internal struct Reader: ~Copyable {
            let stream: Terminal.Stream
            let configuration: Configuration
            var token: Terminal.Mode.Raw.Token
            var parseBuffer: ContiguousArray<Byte>
        }
    }

    extension Console.Input.Reader {

        static func start(
            stream: Terminal.Stream,
            configuration: Console.Input.Configuration
        ) throws(Console.Input.Error) -> Self {
            let token: Terminal.Mode.Raw.Token
            do throws(Terminal.Error) {
                token = try stream.mode.raw.enter()
            } catch {
                throw .terminal(error)
            }

            var reader = Self(
                stream: stream,
                configuration: configuration,
                token: token,
                parseBuffer: ContiguousArray()
            )

            do throws(Console.Input.Error) {
                try reader.writeEnableSequences()
            } catch {

                do throws(Terminal.Error) {
                    try reader.token.restore()
                } catch {}
                throw error
            }

            return reader
        }

        mutating func stop() throws(Console.Input.Error) {
            var writeError: Console.Input.Error?
            do throws(Console.Input.Error) {
                try writeDisableSequences()
            } catch {
                writeError = error
            }

            do throws(Terminal.Error) {
                try token.restore()
            } catch {

                throw .terminal(error)
            }

            if let writeError {
                throw writeError
            }
        }

        mutating func nextEvent() throws(Console.Input.Error) -> Terminal.Input.Event? {
            while true {

                if !parseBuffer.isEmpty {
                    var input = Input.Buffer(parseBuffer)

                    do throws(Terminal.Input.Parser.Error) {
                        let event = try Terminal.Input.Parser.parse(&input)

                        let consumed = Int(bitPattern: input.consumed)
                        parseBuffer.removeFirst(consumed)
                        return event
                    } catch Terminal.Input.Parser.Error.incompleteSequence {

                    } catch Terminal.Input.Parser.Error.emptyInput {

                    } catch {
                        throw .parser(error)
                    }
                }

                let bytesRead = try readBytes()
                if bytesRead == 0 {
                    return nil
                }
            }
        }
    }

    extension Console.Input.Reader {

        private mutating func readBytes() throws(Console.Input.Error) -> Int {
            let bytesRead: Int
            do throws(Kernel.IO.Read.Error) {
                bytesRead = try unsafe withUnsafeTemporaryAllocation(
                    byteCount: 4096,
                    alignment: 1
                ) { rawBuffer throws(Kernel.IO.Read.Error) -> Int in
                    let n = try unsafe stream.read(into: rawBuffer)
                    if n > 0 {
                        let typed = unsafe UnsafeBufferPointer(
                            start: rawBuffer.baseAddress!.assumingMemoryBound(to: Byte.self),
                            count: n
                        )
                        unsafe self.parseBuffer.append(contentsOf: typed)
                    }
                    return n
                }
            } catch {
                throw .read(error)
            }
            return bytesRead
        }
    }

    extension Console.Input.Reader {

        private func writeEnableSequences() throws(Console.Input.Error) {
            if configuration.mouse {
                try write(Terminal.Mode.Mouse.Any.enable)
                try write(Terminal.Mode.Mouse.SGR.enable)
            }
            if configuration.paste {
                try write(Terminal.Mode.Paste.enable)
            }
            if configuration.kitty {
                try write(Terminal.Mode.Keyboard.enable)
            }
        }

        private func writeDisableSequences() throws(Console.Input.Error) {
            if configuration.kitty {
                try write(Terminal.Mode.Keyboard.disable)
            }
            if configuration.paste {
                try write(Terminal.Mode.Paste.disable)
            }
            if configuration.mouse {
                try write(Terminal.Mode.Mouse.SGR.disable)
                try write(Terminal.Mode.Mouse.Any.disable)
            }
        }

        private func write(_ string: Swift.String) throws(Console.Input.Error) {
            do throws(Kernel.IO.Write.Error) {
                try stream.write(string.utf8.map(Byte.init))
            } catch {
                throw .write(error)
            }
        }
    }

#endif
