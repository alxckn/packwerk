# typed: strict
# frozen_string_literal: true

require "ast/node"
require "slim"
require "parser/source/buffer"

module Packwerk
  module Parsers
    class Slim
      extend T::Sig

      include ParserInterface

      sig { params(parser_class: T.untyped, ruby_parser: Ruby).void }
      def initialize(parser_class: ::Slim::Engine, ruby_parser: Ruby.new)
        @parser_class = T.let(parser_class, T.class_of(::Slim::Engine))
        @ruby_parser = ruby_parser
      end

      sig { override.params(io: T.any(IO, StringIO), file_path: String).returns(T.untyped) }
      def call(io:, file_path: "<unknown>")
        parse_slim_string(io.read, file_path: file_path)
      end

      sig { params(slim_str: String, file_path: String).returns(T.nilable(AST::Node)) }
      def parse_slim_string(slim_str, file_path:)
        ruby_str = @parser_class.new.call(slim_str)

        @ruby_parser.call(
          io: StringIO.new(ruby_str),
          file_path: file_path,
        )
      rescue EncodingError => e
        result = ParseResult.new(file: file_path, message: e.message)
        raise Parsers::ParseError, result
      rescue Parser::SyntaxError => e
        result = ParseResult.new(file: file_path, message: "Syntax error: #{e}")
        raise Parsers::ParseError, result
      end
    end
  end
end
