# typed: true
# frozen_string_literal: true

require "test_helper"

module Packwerk
  module Parsers
    class SlimTest < Minitest::Test
      include TypedMock

      test "#call returns node with valid file" do
        node = File.open(fixture_path("valid.slim"), "r") do |fixture|
          Slim.new.call(io: fixture)
        end

        assert_kind_of(::AST::Node, node)
      end

      private

      def fixture_path(name)
        ROOT.join("test/fixtures/formats/slim", name).to_s
      end
    end
  end
end
