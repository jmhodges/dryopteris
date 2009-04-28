require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestFeedparser < Test::Unit::TestCase
  def test_applet
    assert_safe_desc(
                "safe<applet code=\"foo.class\" codebase=\"http://example.com/\"></applet> <b>description</b>"
                 )
  end

  def test_blink_removal
    assert_clean "safe description", "<blink>safe</blink> description"
  end

  def test_embed
    assert_safe_desc(
                 "safe<embed src=\"http://example.com\"> <b>description</b>"
                 )
  end

  def test_frameset
    assert_safe_desc(
                 "safe<frameset rows=\"*\"><frame src=\"http://example.com\"></frameset> <b>description</b>")
  end

  def test_iframe
    assert_safe_desc(
                "safe<iframe src=\"http://example.com\"> <b>description</b></iframe>")
  end

  def test_link
    assert_safe_desc(
                 "safe<link rel=\"stylesheet\" type=\"text/css\" href=\"http://example.com/evil.css\"> <b>description</b>")
  end

  def test_meta
    assert_safe_desc "safe<meta http-equiv=\"Refresh\" content=\"0; URL=http://example.com/\"> <b>description</b>"
  end

  def test_object
    assert_safe_desc "safe<object classid=\"clsid:C932BA85-4374-101B-A56C-00AA003668DC\"> <b>description</b>"
  end

  def test_javascript_event_attributes
    %w(onabort onblur onchange onclick ondblclick onerror onfocus onkeydown
       onkeypress onkeyup onload onmousedown onmouseout onmouseover onmouseup
       onreset onresize onsubmit onunload  
      ).each do |prop|
      assert_removed_attr prop
    end
  end

  def test_script
    assert_clean("safe description",
                 "safe<script type=\"text/javascript\">location.href='http:/'+'/example.com/';</script> description")
  end

  def test_inline_script
    assert_clean("<div>safe description</div>",
                 "<div xmlns=\"http://www.w3.org/1999/xhtml\">safe<script type=\"text/javascript\">location.href='http:/'+'/example.com/';</script> description</div>")
  end

  def test_style
    assert_clean("<a href=\"http://www.ragingplatypus.com/\">never trust your upstream platypus</a>",
                 "a href=\"http://www.ragingplatypus.com/\" style=\"display:block; position:absolute; left:0; top:0; width:100%; height:100%; z-index:1; background-color:black; background-image:url(http://www.ragingplatypus.com/i/cam-full.jpg); background-x:center; background-y:center; background-repeat:repeat;\">never trust your upstream platypus</a>")
  end

  def test_crazy
    crazy = File.open('crazy.html').read
    sane = "Crazy HTML -- Can Your Regex Parse This?\n\n\n\n<!-" +
      "- <script> -->\n\n<!-- \n\t<script> \n-" +
      "->\n\n\n\nfunction executeMe()\n{\n\n\n\n\n/* \n<h1>Did The" +
      " Javascript Execute?</h1>\n<div>\nI will execute here, too, if you " +
      "mouse over me\n</div>"
    assert_clean(sane, crazy)
  end

  private
  def assert_removed_attr(attr_string)
    original = "<img src=\"http://www.ragingplatypus.com/i/cam-full.jpg\ #{attr_string}=\"location.href='http://www.ragingplatypus.com/';\" />"
    assert_clean(
                 "<img src=\"http://www.ragingplatypus.com/i/cam-full.jpg\" />",
                 original
                 )
  end

  def assert_safe_desc(original)
    assert_clean("safe <b>description</b>", original)
  end

  def assert_clean(expected, original_html, message=nil)
    assert_equal expected, Dryopteris.whitewash(original_html)
  end
end
