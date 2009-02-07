require "rubygems"
require "spec"

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "js_flay"))

describe "jsflay" do
  def sexp(js)
    Johnson.parse(js)
  end
  
  before :each do
    @neg_sexp = sexp("function neg(bar) { return bar * -1; }")
    @baz_sexp = sexp("function baz(bop) { return bop * 1; }")
  end
  
  it "should have structure" do
    sexp("variableName").structure.should == [[:name]]
    sexp("var baz").structure.should == [[:var, [[:name]]]]
    @neg_sexp.structure.should == [[:func_expr, [[:return, [:op_multiply, [:name], [:lit]]]]]]
    @baz_sexp.structure.should == [[:func_expr, [[:return, [:op_multiply, [:name], [:lit]]]]]]
  end
  
  it "should calculate the mass of JS sexps" do
    sexp("variableName").mass.should == 1
    sexp("var1; var2; var3").mass.should == 3
    sexp("function neg(bar) { return bar * -1; }").mass.should == 5
  end
  
  it "should hash fuzzily" do
    @neg_sexp.fuzzy_hash.should == @baz_sexp.fuzzy_hash
  end
  
  describe "finding duplicate structures" do
    it "should not find different structures" do
      js_flay = JSFlay.new(2, false)
      js_flay.process "var foo = 1;"
      js_flay.process "2 * 10"
      js_flay.duplicates.should == []
    end
    
    it "should find duplicate structures" do
      js_flay = JSFlay.new(2, false)
      js_flay.process "var foo = 1;"
      js_flay.process "var bar = 2"
      js_flay.duplicates.size.should == 1
    end
    
    it "should find nested duplicate structures" do
      js_flay = JSFlay.new(2, false)
      js_flay.process "function bar() { var foo = 1; }"
      js_flay.process "if (true) { var bar = 2; }"
      js_flay.duplicates.size.should == 1
    end
    
    it "should identify duplication by filename" do
      js_flay = JSFlay.new(2, false)
      js_flay.process "var foo = 1;", "foo.js"
      js_flay.process "var bar = 2;", "bar.js"
      js_flay.format_duplicate(js_flay.duplicates.first).should include("foo.js")
      js_flay.format_duplicate(js_flay.duplicates.first).should include("bar.js")
    end
    
    it "should identify duplication mass" do
      js_flay = JSFlay.new(2, false)
      js_flay.process "var foo = 1;", "foo.js"
      js_flay.process "var bar = 2;", "bar.js"
      js_flay.format_duplicate(js_flay.duplicates.first).should include("mass = 8")
    end
  end
end