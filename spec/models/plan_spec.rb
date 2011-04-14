require 'spec_helper'

describe Plan do
  describe "#clean_text" do
    subject { Plan.new }
    def it_converts_text input, expected
      subject.edit_text = input
      subject.clean_text
      subject.plan.should == "<p class=\"sub\">#{expected}</p>"
    end

    it "is called on save" do
      subject.expects( :clean_text )
      subject.save
    end

    it "scrubs disallowed html" do
      input = "<script>alert('foo');</script> image: <img src=\"foo.jpg\" />"
      expected = "alert('foo'); image: "
      it_converts_text input, expected
    end

    it "wraps paragraphs at <hr>" do
      input = "foo<hr>bar"
      expected = "<p class=\"sub\">foo</p><hr><p class=\"sub\">bar</p>"
      subject.edit_text = input
      subject.clean_text
      subject.plan.should == expected
    end

    it "wraps paragraphs at <pre>" do
      input = "foo<pre>bar</pre>"
      expected = "<p class=\"sub\">foo</p><pre class=\"sub\">bar</pre><p class=\"sub\">"
      subject.edit_text = input
      subject.clean_text
      subject.plan.should == expected
    end

    context "safe html" do
      def accepts_tag name
        input = "<#{name}>Some text</#{name}>"
        it_converts_text input, input
      end
      def converts_tag name, new_open, new_close
        input = "<#{name}>Some text</#{name}>"
        expected = "<#{new_open}>Some text</#{new_close}>"
        it_converts_text input, expected
      end
      it { accepts_tag "i" }
      it { accepts_tag "b" }
      it { accepts_tag "span" }
      it { accepts_tag "code" }
      it { accepts_tag "tt" }
      it { converts_tag "u", "span class=\"underline\"", "span" }
      it { converts_tag "s", "span class=\"strike\"", "span" }
      it { converts_tag "strike", "span class=\"strike\"", "span" }
    end

    it "escapes non-tag brackets" do
      input = "foo < bar << baz > foo"
      expected = "foo &lt; bar &lt;&lt; baz &gt; foo"
      it_converts_text input, expected
    end

    it "allows html but strips disallowed elements" do
      input = "<span class=\"foo\" rel=\"self\" onClick='alert(\"bar\");'>Foo bar</span>"
      expected = "<span class=\"foo\">Foo bar</span>"
      it_converts_text input, expected
    end

    it "disallows other link protocols" do
      input = "<a href='javascript:alert(\"foo\");'>Hi!</a>"
      expected = "<a>Hi!</a>"
      it_converts_text input, expected
    end

    it "supports inline code" do
      input = "foo `bar   <script>baz</script>` foo"
      expected = "foo <code>bar   <script>baz</script></code> foo"
      it_converts_text input, expected
    end

    it "parses link format" do
      pending do
        input = "here is a [http://google.com|link]!"
        expected = "here is a <a href=\"http://google.com\">link</a>!"
        it_converts_text input, expected
      end
    end

    it "parses planlove" do
      pending do
        oscar = Account.create! :username => "wildeosc", :password => "foobar", :password_confirmation => "foobar"
        input = "planlove [wildeosc]."
        expected = "planlove [<a href=\"#{Rails.application.routes.url_helpers.read_path oscar.username}\" class=\"onplan\">wildosc</a>]."
        it_converts_text input, expected
      end
    end
  end
end
