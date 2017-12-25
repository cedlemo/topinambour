#!/usr/bin/env ruby
require "minitest/autorun"
require "fileutils"
require "gtk3"

PATH = File.expand_path(File.dirname("__FILE__"))
LIB_PATH = "#{PATH}/../lib"

require "#{LIB_PATH}/rgb_names_regexes"
require "#{LIB_PATH}/terminal_regex"

def switch_assert(val, string, result)
  case result
  when :ENTIRE
    assert_equal(string, val)
  when :NULL
    assert_nil(val)
  else
    assert_equal(result, val)
  end
end

def assert_match_anchored(constant_name, string, result)
  pattern = TopinambourRegex.const_get(constant_name)
  regex = GLib::Regex.new(pattern)
  match_info = regex.match(string, :match_options => GLib::RegexMatchFlags::ANCHORED)
  switch_assert(match_info.fetch(0), string, result)
end

def assert_match_anchored_extended(constant_name, additional_pattern, string, result)
  pattern = TopinambourRegex.const_get(constant_name)
  regex = GLib::Regex.new(pattern + additional_pattern)
  match_info = regex.match(string, :match_options => GLib::RegexMatchFlags::ANCHORED)
  switch_assert(match_info.fetch(0), string, result)
end

def assert_match_anchored_added(constant_names, string, result)
  pattern = ""
  constant_names.each do |name|
    pattern += TopinambourRegex.const_get(name)
  end
  regex = GLib::Regex.new(pattern)
  match_info = regex.match(string, :match_options => GLib::RegexMatchFlags::ANCHORED)
  switch_assert(match_info.fetch(0), string, result)
end

def assert_match_b(constant_name, string, result)
  pattern = TopinambourRegex.const_get(constant_name)
  regex = GLib::Regex.new(pattern)
  match_info = regex.match(string)
  switch_assert(match_info.fetch(0), string, result)
end

def assert_match_extended(constant_name, additional_pattern, string, result)
  pattern = TopinambourRegex.const_get(constant_name)
  regex = GLib::Regex.new(pattern + additional_pattern)
  match_info = regex.match(string)
  switch_assert(match_info.fetch(0), string, result)
end

def assert_match_added(constant_names, string, result)
  pattern = ""
  constant_names.each do |name|
    pattern += TopinambourRegex.const_get(name)
  end
  regex = GLib::Regex.new(pattern)
  match_info = regex.match(string)
  switch_assert(match_info.fetch(0), string, result)
end

class TestTerminalRegexBasics < MiniTest::Test
  def test_scheme
    assert_match_anchored(:SCHEME, "http", :ENTIRE)
    assert_match_anchored(:SCHEME,"HTTPS",:ENTIRE)
  end

  def test_user
    assert_match_anchored(:USER, "",              :NULL);
    assert_match_anchored(:USER, "dr.john-smith", :ENTIRE);
    assert_match_anchored(:USER, "abc+def@ghi",   "abc+def");
  end

  def test_pass
    assert_match_anchored(:PASS, "",          :ENTIRE);
    assert_match_anchored(:PASS, "nocolon",   "");
    assert_match_anchored(:PASS, ":s3cr3T",   :ENTIRE);
    assert_match_anchored(:PASS, ":$?\#@host", ":$?#");
  end

  def test_hostname1
    assert_match_anchored(:HOSTNAME1, "example.com",       :ENTIRE)
    assert_match_anchored(:HOSTNAME1, "a-b.c-d",           :ENTIRE)
    assert_match_anchored(:HOSTNAME1, "a_b",               "a") # TODO: can/should we totally abort here? */
    assert_match_anchored(:HOSTNAME1, "déjà-vu.com",       :ENTIRE)
    assert_match_anchored(:HOSTNAME1, "➡.ws",              :ENTIRE)
    assert_match_anchored(:HOSTNAME1, "cömbining-áccents", :ENTIRE)
    assert_match_anchored(:HOSTNAME1, "12",                :NULL)
    assert_match_anchored(:HOSTNAME1, "12.34",             :NULL)
    assert_match_anchored(:HOSTNAME1, "12.ab",             :ENTIRE)
    #assert_match_anchored(:HOSTNAME1, "ab.12",             :NULL)
  end

  def test_hostname2
    assert_match_anchored(:HOSTNAME2, "example.com",       :ENTIRE)
    assert_match_anchored(:HOSTNAME2, "example",           :NULL)
    assert_match_anchored(:HOSTNAME2, "12",                :NULL)
    assert_match_anchored(:HOSTNAME2, "12.34",             :NULL)
    assert_match_anchored(:HOSTNAME2, "12.ab",             :ENTIRE)
    assert_match_anchored(:HOSTNAME2, "ab.12",             :NULL)
    # assert_match_anchored(:HOSTNAME2, "ab.cd.12",          :NULL)#  /* errr... could we fail here?? */
  end

  def test_defs_ipv4_1
    assert_match_anchored_extended(:DEFS, "(?&S4)", "0",                :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "1",                :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "9",                :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "10",               :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "99",               :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "100",              :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "200",              :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "250",              :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "255",              :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "256",              :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "260",              :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "300",              :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "1000",             :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "",                 :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "a1b",              :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV4)", "11.22.33.44",    :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&IPV4)", "0.1.254.255",    :ENTIRE)
  end

  def test_defs_ipv4_2
    assert_match_anchored_extended(:DEFS, "(?&IPV4)", "75.150.225.300", :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV4)", "1.2.3.4.5",      "1.2.3.4")
    assert_match_anchored_extended(:DEFS, "(?&S4)", "0",    :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "1",    :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "9",    :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "10",   :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "99",   :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "100",  :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "200",  :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "250",  :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "255",  :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "256",  :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "260",  :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "300",  :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "1000", :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "",     :NULL)
    assert_match_anchored_extended(:DEFS, "(?&S4)", "a1b",  :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV4)", "11.22.33.44",    :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&IPV4)", "0.1.254.255",    :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&IPV4)", "75.150.225.300", :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV4)", "1.2.3.4.5",      "1.2.3.4")#  /* we could also bail out and not match at all */ #  /* USER is nonempty, alphanumeric, dot, plus and dash */
  end

  def test_defs_ipv6_1
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:::22",                           :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22::33:44::55:66",               :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "dead::beef",                        :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "faded::bee",                        :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "live::pork",                        :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "::1",                               :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11::22:33::44",                     :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:::33",                        :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "dead:beef::192.168.1.1",            :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "192.168.1.1",                       :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:77:87654",        :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22::33:45678",                   :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:192.168.1.12345", :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:77",              :NULL)   #/* no :: */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:77:88",           :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:77:88:99",        :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "::11:22:33:44:55:66:77",            :ENTIRE) #/* :: at the start */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "::11:22:33:44:55:66:77:88",         :NULL)
  end

  def test_defs_ipv6_2
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33::44:55:66:77",             :ENTIRE) #/* :: in the middle */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33::44:55:66:77:88",          :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:77::",            :ENTIRE) #/* :: at the end */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:77:88::",         :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "::",                                :ENTIRE) #/* :: only */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:192.168.1.1",        :NULL)   #/* no :: */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:192.168.1.1",     :ENTIRE)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66:77:192.168.1.1",  :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "::11:22:33:44:55:192.168.1.1",      :ENTIRE) #/* :: at the start */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "::11:22:33:44:55:66:192.168.1.1",   :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33::44:55:192.168.1.1",       :ENTIRE) #/* :: in the imddle */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33::44:55:66:192.168.1.1",    :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55::192.168.1.1",       :ENTIRE) #/* :: at the end(ish) */
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "11:22:33:44:55:66::192.168.1.1",    :NULL)
    assert_match_anchored_extended(:DEFS, "(?&IPV6)", "::192.168.1.1",                     :ENTIRE) #/* :: only(ish) */
  end

  def test_url_host
    assert_match_anchored_added([:DEFS, :URL_HOST], "example",       :ENTIRE)
    assert_match_anchored_added([:DEFS, :URL_HOST], "example.com",   :ENTIRE)
    assert_match_anchored_added([:DEFS, :URL_HOST], "11.22.33.44",   :ENTIRE)
    assert_match_anchored_added([:DEFS, :URL_HOST], "[11.22.33.44]", :NULL)
    assert_match_anchored_added([:DEFS, :URL_HOST], "dead::be:ef",   "dead")  #/* TODO: can/should we totally abort here? */
    assert_match_anchored_added([:DEFS, :URL_HOST], "[dead::be:ef]", :ENTIRE)
  end

  def test_email_host
    assert_match_anchored_added([:DEFS, :EMAIL_HOST], "example",        :NULL)
    assert_match_anchored_added([:DEFS, :EMAIL_HOST], "example.com",    :ENTIRE)
    assert_match_anchored_added([:DEFS, :EMAIL_HOST], "11.22.33.44",    :NULL)
    assert_match_anchored_added([:DEFS, :EMAIL_HOST], "[11.22.33.44]",  :ENTIRE)
    assert_match_anchored_added([:DEFS, :EMAIL_HOST], "[11.22.33.456]", :NULL)
    assert_match_anchored_added([:DEFS, :EMAIL_HOST], "dead::be:ef",    :NULL)
    assert_match_anchored_added([:DEFS, :EMAIL_HOST], "[dead::be:ef]",  :ENTIRE)
  end

  def test_port_nums
    assert_match_anchored(:N_1_65535, "0",      :NULL)
    assert_match_anchored(:N_1_65535, "1",      :ENTIRE)
    assert_match_anchored(:N_1_65535, "10",     :ENTIRE)
    assert_match_anchored(:N_1_65535, "100",    :ENTIRE)
    assert_match_anchored(:N_1_65535, "1000",   :ENTIRE)
    assert_match_anchored(:N_1_65535, "10000",  :ENTIRE)
    assert_match_anchored(:N_1_65535, "60000",  :ENTIRE)
    assert_match_anchored(:N_1_65535, "65000",  :ENTIRE)
    assert_match_anchored(:N_1_65535, "65500",  :ENTIRE)
    assert_match_anchored(:N_1_65535, "65530",  :ENTIRE)
    assert_match_anchored(:N_1_65535, "65535",  :ENTIRE)
    assert_match_anchored(:N_1_65535, "65536",  :NULL)
    assert_match_anchored(:N_1_65535, "65540",  :NULL)
    assert_match_anchored(:N_1_65535, "65600",  :NULL)
    assert_match_anchored(:N_1_65535, "66000",  :NULL)
    assert_match_anchored(:N_1_65535, "70000",  :NULL)
    assert_match_anchored(:N_1_65535, "100000", :NULL)
    assert_match_anchored(:N_1_65535, "",       :NULL)
    assert_match_anchored(:N_1_65535, "a1b",    :NULL)
  end

  def test_port
    assert_match_anchored(:PORT, "",       :ENTIRE)
    assert_match_anchored(:PORT, ":1",     :ENTIRE)
    assert_match_anchored(:PORT, ":65535", :ENTIRE)
    assert_match_anchored(:PORT, ":65536", "") #    TODO: can/should we totally abort here? */
  end

  def test_url_path
    assert_match_anchored_added([:DEFS, :URLPATH], "/ab/cd",       :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/ab/cd.html.", "/ab/cd.html")
    assert_match_anchored_added([:DEFS, :URLPATH], "/The_Offspring_(album)", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/The_Offspring)", "/The_Offspring")
    assert_match_anchored_added([:DEFS, :URLPATH], "/a((b(c)d)e(f))", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/a((b(c)d)e(f)))", "/a((b(c)d)e(f))")
    assert_match_anchored_added([:DEFS, :URLPATH], "/a(b).(c).", "/a(b).(c)")
    assert_match_anchored_added([:DEFS, :URLPATH], "/a.(b.(c.).).(d.(e.).).)", "/a.(b.(c.).).(d.(e.).)")
    assert_match_anchored_added([:DEFS, :URLPATH], "/a)b(c", "/a")
    assert_match_anchored_added([:DEFS, :URLPATH], "/.", "/")
    assert_match_anchored_added([:DEFS, :URLPATH], "/(.", "/")
    assert_match_anchored_added([:DEFS, :URLPATH], "/).", "/")
    assert_match_anchored_added([:DEFS, :URLPATH], "/().", "/()")
    assert_match_anchored_added([:DEFS, :URLPATH], "/", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/php?param[]=value1&param[]=value2", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/foo?param1[index1]=value1&param2[index2]=value2", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/[[[]][]]", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/[([])]([()])", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/([()])[([])]", :ENTIRE)
    assert_match_anchored_added([:DEFS, :URLPATH], "/[(])", "/")
    assert_match_anchored_added([:DEFS, :URLPATH], "/([)]", "/")
  end
end

class TestTerminalRegexComplex < MiniTest::Test
  def test_url_as_is_1
    assert_match_b(:REGEX_URL_AS_IS, "There's no URL here http:/foo",               :NULL)
    assert_match_b(:REGEX_URL_AS_IS, "Visit http://example.com for details",        "http://example.com")
    assert_match_b(:REGEX_URL_AS_IS, "Trailing dot http://foo/bar.html.",           "http://foo/bar.html")
    assert_match_b(:REGEX_URL_AS_IS, "Trailing ellipsis http://foo/bar.html...",    "http://foo/bar.html")
    assert_match_b(:REGEX_URL_AS_IS, "See <http://foo/bar>",                        "http://foo/bar")
    assert_match_b(:REGEX_URL_AS_IS, "<http://foo.bar/asdf.qwer.html>",             "http://foo.bar/asdf.qwer.html")
    assert_match_b(:REGEX_URL_AS_IS, "Go to http://192.168.1.1.",                   "http://192.168.1.1")
    assert_match_b(:REGEX_URL_AS_IS, "If not, see <http://www.gnu.org/licenses/>.", "http://www.gnu.org/licenses/")
    assert_match_b(:REGEX_URL_AS_IS, "<a href=\"http://foo/bar\">foo</a>",          "http://foo/bar")
    assert_match_b(:REGEX_URL_AS_IS, "<a href='http://foo/bar'>foo</a>",            "http://foo/bar")
    assert_match_b(:REGEX_URL_AS_IS, "<url>http://foo/bar</url>",                   "http://foo/bar")
    assert_match_b(:REGEX_URL_AS_IS, "http://",          :NULL)
    assert_match_b(:REGEX_URL_AS_IS, "http://a",         :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://aa.",       "http://aa")
    assert_match_b(:REGEX_URL_AS_IS, "http://aa.b",      :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://aa.bb",     :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://aa.bb/c",   :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://aa.bb/cc",  :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://aa.bb/cc/", :ENTIRE)
  end

  def test_url_as_is_2
    assert_match_b(:REGEX_URL_AS_IS, "HtTp://déjà-vu.com:10000/déjà/vu",    :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "HTTP://joe:sEcReT@➡.ws:1080",         :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "https://cömbining-áccents",           :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://111.222.33.44",                :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://111.222.33.44/",               :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://111.222.33.44/foo",            :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://1.2.3.4:5555/xyz",             :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "https://[dead::beef]:12345/ipv6",     :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "https://[dead::beef:11.22.33.44]",    :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://1.2.3.4:",                     "http://1.2.3.4")#  /* TODO: can/should we totally abort here? */
    assert_match_b(:REGEX_URL_AS_IS, "https://dead::beef/no-brackets-ipv6", "https://dead")#    /* detto */
    assert_match_b(:REGEX_URL_AS_IS, "http://111.222.333.444/",             :NULL)
    assert_match_b(:REGEX_URL_AS_IS, "http://1.2.3.4:70000",                "http://1.2.3.4") #  /* TODO: can/should we totally abort here? */
    assert_match_b(:REGEX_URL_AS_IS, "http://[dead::beef:111.222.333.444]", :NULL)
    #  /* Username, password */
    assert_match_b(:REGEX_URL_AS_IS, "http://joe@example.com",                 :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://user.name:sec.ret@host.name",     :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://joe:secret@[::1]",                :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://dudewithnopassword:@example.com", :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://safeguy:!#$%^&*@host",            :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http://invalidusername!@host",           "http://invalidusername")
    assert_match_b(:REGEX_URL_AS_IS, "http://ab.cd/ef?g=h&i=j|k=l#m=n:o=p", :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "http:///foo",                         :NULL)
    assert_match_b(:REGEX_URL_AS_IS, "https://en.wikipedia.org/wiki/The_Offspring_(album)", :ENTIRE)
    assert_match_b(:REGEX_URL_AS_IS, "[markdown](https://en.wikipedia.org/wiki/The_Offspring)", "https://en.wikipedia.org/wiki/The_Offspring")
    assert_match_b(:REGEX_URL_AS_IS, "[markdown](https://en.wikipedia.org/wiki/The_Offspring_(album))", "https://en.wikipedia.org/wiki/The_Offspring_(album)")
    assert_match_b(:REGEX_URL_AS_IS, "[markdown](http://foo.bar/(a(b)c)d)e)f", "http://foo.bar/(a(b)c)d")
    assert_match_b(:REGEX_URL_AS_IS, "[markdown](http://foo.bar/a)b(c", "http://foo.bar/a")
  end

  def test_url_http
    assert_match_b(:REGEX_URL_HTTP, "www.foo.bar/baz",     :ENTIRE)
    assert_match_b(:REGEX_URL_HTTP, "WWW3.foo.bar/baz",    :ENTIRE)
    assert_match_b(:REGEX_URL_HTTP, "FTP.FOO.BAR/BAZ",     :ENTIRE) # FIXME if no scheme is given and url starts with ftp, can we make the protocol ftp instead of http?
    assert_match_b(:REGEX_URL_HTTP, "ftpxy.foo.bar/baz",   :ENTIRE)
    assert_match_b(:REGEX_URL_HTTP, "foo.bar/baz",         :NULL)
    assert_match_b(:REGEX_URL_HTTP, "abc.www.foo.bar/baz", :NULL)
    assert_match_b(:REGEX_URL_HTTP, "uvwww.foo.bar/baz",   :NULL)
    assert_match_b(:REGEX_URL_HTTP, "xftp.foo.bar/baz",    :NULL)
  #//  assert_match(REGEX_URL_HTTP, "ftp.123/baz",         NULL);  /* errr... could we fail here?? */
  end

  def test_url_file
    assert_match_b(:REGEX_URL_FILE, "file:",                :NULL)
    assert_match_b(:REGEX_URL_FILE, "file:/",               :ENTIRE)
    assert_match_b(:REGEX_URL_FILE, "file://",              :NULL)
    assert_match_b(:REGEX_URL_FILE, "file:///",             :ENTIRE)
    assert_match_b(:REGEX_URL_FILE, "file:////",            :NULL)
    assert_match_b(:REGEX_URL_FILE, "file:etc/passwd",      :NULL)
    assert_match_b(:REGEX_URL_FILE, "File:/etc/passwd",     :ENTIRE)
    assert_match_b(:REGEX_URL_FILE, "FILE:///etc/passwd",   :ENTIRE)
    assert_match_b(:REGEX_URL_FILE, "file:////etc/passwd",  :NULL)
    assert_match_b(:REGEX_URL_FILE, "file://host.name",     :NULL)
    assert_match_b(:REGEX_URL_FILE, "file://host.name/",    :ENTIRE)
    assert_match_b(:REGEX_URL_FILE, "file://host.name/etc", :ENTIRE)
    assert_match_b(:REGEX_URL_FILE, "See file:/.",             "file:/")
    assert_match_b(:REGEX_URL_FILE, "See file:///.",           "file:///")
    assert_match_b(:REGEX_URL_FILE, "See file:/lost+found.",   "file:/lost+found")
    assert_match_b(:REGEX_URL_FILE, "See file:///lost+found.", "file:///lost+found")
  end

  def test_regex_email
    assert_match_b(:REGEX_EMAIL, "Write to foo@bar.com.",        "foo@bar.com")
    assert_match_b(:REGEX_EMAIL, "Write to <foo@bar.com>",       "foo@bar.com")
    assert_match_b(:REGEX_EMAIL, "Write to mailto:foo@bar.com.", "mailto:foo@bar.com")
    assert_match_b(:REGEX_EMAIL, "Write to MAILTO:FOO@BAR.COM.", "MAILTO:FOO@BAR.COM")
    assert_match_b(:REGEX_EMAIL, "Write to foo@[1.2.3.4]",       "foo@[1.2.3.4]")
    assert_match_b(:REGEX_EMAIL, "Write to foo@[1.2.3.456]",     :NULL)
    assert_match_b(:REGEX_EMAIL, "Write to foo@[1::2345]",       "foo@[1::2345]")
    assert_match_b(:REGEX_EMAIL, "<baz email=\"foo@bar.com\"/>", "foo@bar.com")
    assert_match_b(:REGEX_EMAIL, "<baz email='foo@bar.com'/>",   "foo@bar.com")
    assert_match_b(:REGEX_EMAIL, "<email>foo@bar.com</email>",   "foo@bar.com")
  end

  def test_regex_url_voip
    assert_match_b(:REGEX_URL_VOIP, "sip:alice@atlanta.com;maddr=239.255.255.1;ttl=15",           :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "sip:alice@atlanta.com",                                      :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "sip:alice:secretword@atlanta.com;transport=tcp",             :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "sips:alice@atlanta.com?subject=project%20x&priority=urgent", :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "sip:+1-212-555-1212:1234@gateway.com;user=phone",            :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "sips:1212@gateway.com",                                      :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "sip:alice@192.0.2.4",                                        :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "sip:atlanta.com;method=REGISTER?to=alice%40atlanta.com",     :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "SIP:alice;day=tuesday@atlanta.com",                          :ENTIRE)
    assert_match_b(:REGEX_URL_VOIP, "Dial sip:alice@192.0.2.4.",                                  "sip:alice@192.0.2.4");
  end
end

class TestColorsRegex < MiniTest::Test
  def test_hex_class
    assert_match_b(:HEX_CLASS, "a", :ENTIRE)
    assert_match_b(:HEX_CLASS, "c", :ENTIRE)
    assert_match_b(:HEX_CLASS, "f", :ENTIRE)
    assert_match_b(:HEX_CLASS, "A", :ENTIRE)
    assert_match_b(:HEX_CLASS, "C", :ENTIRE)
    assert_match_b(:HEX_CLASS, "F", :ENTIRE)
    assert_match_b(:HEX_CLASS, "0", :ENTIRE)
    assert_match_b(:HEX_CLASS, "5", :ENTIRE)
    assert_match_b(:HEX_CLASS, "9", :ENTIRE)
    assert_match_b(:HEX_CLASS, "_", :NULL)
  end

  def test_uint8_class
    assert_match_b(:UINT8_CLASS, "0", :ENTIRE)
    assert_match_b(:UINT8_CLASS, "000", :ENTIRE)
    assert_match_b(:UINT8_CLASS, "10", :ENTIRE)
    assert_match_b(:UINT8_CLASS, "010", :ENTIRE)
    assert_match_b(:UINT8_CLASS, "125", :ENTIRE)
    assert_match_b(:UINT8_CLASS, "255", :ENTIRE)
    assert_match_b(:UINT8_CLASS, "256", :NULL)
  end

  def test_percent_class
    assert_match_b(:PERCENT_CLASS, "02%", :ENTIRE)
    assert_match_b(:PERCENT_CLASS, "30%", :ENTIRE)
    assert_match_b(:PERCENT_CLASS, "100%", :ENTIRE)
    assert_match_b(:PERCENT_CLASS, "toto%", :NULL)
  end

  def test_hex_color
    assert_match_b(:HEX_COLOR, "#00ff00", :ENTIRE)
    assert_match_b(:HEX_COLOR, "#0f0", :ENTIRE)
    assert_match_b(:HEX_COLOR, "#00ff00ff", :ENTIRE)
  end

  def test_rgb_color
    assert_match_b(:RGB_COLOR, "rgb(100,150,255)", :ENTIRE)
    assert_match_b(:RGB_COLOR, "rgb(100|150,255)", :NULL)
    assert_match_b(:RGB_COLOR, "rgb(350, 150,255)", :NULL)
  end

  def test_rgbperc_color
    assert_match_b(:RGBPERC_COLOR, "rgb(100%,15%,0%)", :ENTIRE)
    assert_match_b(:RGBPERC_COLOR, "rgb(100,150,255)", :NULL)
    assert_match_b(:RGBPERC_COLOR, "rgb(350, 150,255)", :NULL)
  end

  def test_rgba_color
    assert_match_b(:RGBA_COLOR, "rgba(100,150,255, 0.5)", :ENTIRE)
    assert_match_b(:RGBA_COLOR, "rgba(100|150,255)", :NULL)
    assert_match_b(:RGBA_COLOR, "rgba(350, 150,255,123)", :NULL)
  end

  def test_rgbaperc_color
    assert_match_b(:RGBAPERC_COLOR, "rgba(100%,15%,0%, 1.0)", :ENTIRE)
    assert_match_b(:RGBAPERC_COLOR, "rgba(100,150,255)", :NULL)
    assert_match_b(:RGBAPERC_COLOR, "rgba(350, 150,255)", :NULL)
  end

  def test_css_colors
    assert_match_b(:CSS_COLORS, "rgba(100%,15%,0%, 1.0)", :ENTIRE)
    assert_match_b(:CSS_COLORS, "rgba(100,150,255, 0.5)", :ENTIRE)
    assert_match_b(:CSS_COLORS, "rgb(100%,15%,0%)", :ENTIRE)
    assert_match_b(:CSS_COLORS, "rgb(100,150,255)", :ENTIRE)
    assert_match_b(:CSS_COLORS, "#00ff00", :ENTIRE)
    assert_match_b(:CSS_COLORS, "#0f0", :ENTIRE)
    assert_match_b(:CSS_COLORS, "#00ff00ff", :ENTIRE)
  end
end
