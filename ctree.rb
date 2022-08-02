#!/usr/bin/env ruby
input = ARGF.read

PathFile = Struct.new(:name, :children, :parent)

class PathTree
    def initialize
        @root = PathFile.new("", [], nil)
    end

    def add_path(path)
        parts = path.split("/")
        part_count = parts.length
        parent = @root

        parts.each_with_index do |part, index|
            part_name = part.strip
            existing = find_file(parent, part_name)

            if existing.nil?
                path_file = PathFile.new(part_name, [], parent)
                parent.children << path_file
                parent = path_file
            else
                parent = existing
            end
        end
    end

    def print
        walk_tree(@root, -1) do |file, depth|
            end_mark = file.children.length.positive? ? "/" : ""
            puts "#{tab_repeat(depth)}#{file.name}#{end_mark}" unless file.name.empty?
        end
    end

    private

    def walk_tree(current, depth, &block)
        yield current, depth
        current.children.each { |c| walk_tree(c, depth + 1, &block) } unless current.children.empty?
    end

    def find_file(parent, name)
        parent.children.each do |c|
            return c if c.name == name
        end
        nil
    end

    def tab_repeat(n)
        "    " * n
    end
end

tree = PathTree.new
input.each_line do |line|
    tree.add_path(line)
end
tree.print
