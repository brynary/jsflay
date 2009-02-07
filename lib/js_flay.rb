require "johnson"

class Array
  def syms
    symed = map do |a|
      if a.respond_to?(:syms)
        a.syms
      elsif a.is_a?(Symbol)
        a
      else
        nil
      end
    end.compact
    
    return nil if symed.empty?
    symed
  end
end

Johnson::Nodes::Node.class_eval do
  attr_accessor :filename
  
  def mass
    @mass ||= Array(structure).flatten.size
  end
  
  def structure
    to_sexp.syms
  end
  
  def fuzzy_hash
    @fuzzy_hash ||= structure.hash
  end
  
  def all_subhashes
    hashes = []
    self.each do |node|
      hashes << node.fuzzy_hash unless node == self
    end
    hashes
  end
end

class JSFlay
  attr_reader :hashes
  
  def initialize(mass = 20, verbose = true)
    @verbose = verbose
    @hashes = Hash.new { |h,k| h[k] = [] }
    @mass_threshold = mass
  end
  
  def process_files(*files)
    files.each do |file|
      process(File.read(file), file)
    end
  end
  
  def process(js, filename = nil)
    puts "Processing: #{filename}" if @verbose
    sexp = Johnson.parse(js, filename)
    
    sexp.each do |node|
      next if node.mass < @mass_threshold
      node.filename = filename
      @hashes[node.fuzzy_hash] << node
    end
  end
  
  def prune
    @hashes.delete_if { |_, nodes| nodes.size == 1 }
    
    # extract all subtree hashes from all nodes
    all_hashes = {}
    self.hashes.values.each do |nodes|
      nodes.each do |node|
        node.all_subhashes.each do |h|
          all_hashes[h] = true
        end
      end
    end

    # nuke subtrees so we show the biggest matching tree possible
    self.hashes.delete_if { |h,_| all_hashes[h] }
  end
  
  def duplicates
    prune
    @hashes.values
  end
  
  def report
    duplicates.sort_by { |duplicate|
      -(duplicate.first.mass * duplicate.size)
    }.each do |duplicate|
      puts format_duplicate(duplicate)
    end
  end
  
  def format_duplicate(duplicate)
    first = duplicate.first
    mass = first.mass * duplicate.size
    str = ""
    str << "\nMatches found (mass = #{mass})\n"
    duplicate.each do |dupe|
      str << "    #{dupe.filename}:#{dupe.line}\n"
    end
    return str
  end
end