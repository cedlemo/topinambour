# Copyright 2016-2017 Cedric LE MOIGNE, cedlemo@gmx.com
# This file is part of Topinambour.
#
# Topinambour is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# Topinambour is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Topinambour.  If not, see <http://www.gnu.org/licenses/>.

# Stolen from https://github.com/GNOME/gnome-terminal/blob/master/src/terminal-regex.h
module UserPassRegexes
  USERCHARS = "-+.[:alnum:]"
  # Nonempty username, e.g. "john.smith"
  USER = "[#{USERCHARS}]+"
  PASSCHARS_CLASS = '[-[:alnum:]\\Q,?;.:/!%$^*&~\"#\'\\E]'
  # Optional colon-prefixed password. I guess empty password should be allowed, right? E.g. ":secret", ":", "" */
  PASS = "(?x: :#{PASSCHARS_CLASS}* )?"
  # Optional at-terminated username (with perhaps a password too), e.g. "joe@", "pete:secret@", "" */
  USERPASS = "(?:#{USER}#{PASS}@)?"
end

module IpRegexes
  # S4: IPv4 segment (number between 0 and 255) with lookahead at the end so that we don't match "25" in the string "256".
  # The lookahead could go to the last segment of IPv4 only but this construct allows nicer unittesting. */
  S4_DEF = "(?(DEFINE)(?<S4>(?x: (?: [0-9] | [1-9][0-9] | 1[0-9]{2} | 2[0-4][0-9] | 25[0-5] ) (?! [0-9] ) )))"
  # IPV4: Decimal IPv4, e.g. "1.2.3.4", with lookahead (implemented in S4) at the end so that we don't match "192.168.1.123" in the string "192.168.1.1234". */
  IPV4_DEF = "#{S4_DEF}(?(DEFINE)(?<IPV4>(?x: (?: (?&S4) \\. ){3} (?&S4) )))"
  # IPv6, including embedded IPv4, e.g. "::1", "dead:beef::1.2.3.4".
  # Lookahead for the next char not being a dot or digit, so it doesn't get stuck matching "dead:beef::1" in "dead:beef::1.2.3.4".
  # This is not required since the surrounding brackets would trigger backtracking, but it allows nicer unittesting.
  # TODO: more strict check (right number of colons, etc.)
  # TODO: add zone_id: RFC 4007 section 11, RFC 6874 */
  # S6: IPv6 segment, S6C: IPv6 segment followed by a comma, CS6: comma followed by an IPv6 segment */
  S6_DEF = "(?(DEFINE)(?<S6>[[:xdigit:]]{1,4})(?<CS6>:(?&S6))(?<S6C>(?&S6):))"
  # No :: shorthand */
  IPV6_FULL = "(?x: (?&S6C){7} (?&S6) )"
  # Begins with :: */
  IPV6_LEFT = "(?x: : (?&CS6){1,7} )"
  # :: somewhere in the middle - use negative lookahead to make sure there aren't too many colons in total */
  IPV6_MID = "(?x: (?! (?: [[:xdigit:]]*: ){8} ) (?&S6C){1,6} (?&CS6){1,6} )"
  # Ends with :: */
  IPV6_RIGHT = "(?x: (?&S6C){1,7} : )"
  # Is "::" and nothing more */
  IPV6_NULL = "(?x: :: )"
  # The same ones for IPv4-embedded notation, without the actual IPv4 part */
  IPV6V4_FULL = "(?x: (?&S6C){6} )"
  IPV6V4_LEFT = "(?x: :: (?&S6C){0,5} )" # includes "::<ipv4>" */
  IPV6V4_MID  = "(?x: (?! (?: [[:xdigit:]]*: ){7} ) (?&S6C){1,4} (?&CS6){1,4} ) :"
  IPV6V4_RIGHT = "(?x: (?&S6C){1,5} : )"
  # IPV6: An IPv6 address (possibly with an embedded IPv4).
  # This macro defines both IPV4 and IPV6, since the latter one requires the former. */
  IP_DEF = "#{IPV4_DEF}#{S6_DEF}(?(DEFINE)(?<IPV6>(?x: (?: #{IPV6_NULL} | #{IPV6_LEFT} | #{IPV6_MID} | #{IPV6_RIGHT} \
                           | #{IPV6_FULL} | (?: #{IPV6V4_FULL} | #{IPV6V4_LEFT} | #{IPV6V4_MID} | #{IPV6V4_RIGHT} \
                           ) (?&IPV4) ) (?! [.:[:xdigit:]] ) )))"
end

module HostnameRegexes
  # Either an alphanumeric character or dash; or if [negative lookahead] not ASCII
  # then any graphical Unicode character.
  # A segment can consist entirely of numbers.
  # (Note: PCRE doesn't support character class subtraction/intersection.) */
  HOSTNAMESEGMENTCHARS_CLASS = "(?x: [-[:alnum:]] | (?! [[:ascii:]] ) [[:graph:]] )"
  # A hostname of at least 1 component. The last component cannot be entirely numbers.
  # E.g. "foo", "example.com", "1234.com", but not "foo.123" */
  HOSTNAME1 = "(?x: (?: #{HOSTNAMESEGMENTCHARS_CLASS}+ \\. )* " + "#{HOSTNAMESEGMENTCHARS_CLASS}* (?! [0-9] ) #{HOSTNAMESEGMENTCHARS_CLASS}+ )"
  # A hostname of at least 2 components. The last component cannot be entirely numbers.
  # E.g. "example.com", "1234.com", but not "1234.56" */
  HOSTNAME2 = "(?x: (?: #{HOSTNAMESEGMENTCHARS_CLASS}+ \\.)+ #{HOSTNAME1} )"
  # For URL: Hostname, IPv4, or bracket-enclosed IPv6, e.g. "example.com", "1.2.3.4", "[::1]" */
  URL_HOST = "(?x: #{HOSTNAME1} | (?&IPV4) | \\[ (?&IPV6) \\] )"
  # For e-mail: Hostname of at least two segments, or bracket-enclosed IPv4 or IPv6, e.g. "example.com", "[1.2.3.4]", "[::1]".
  # Technically an e-mail with a single-component hostname might be valid on a local network,
  # but let's avoid tons of false positives (e.g. in a typical shell prompt). */
  EMAIL_HOST = "(?x: #{HOSTNAME2} | \\[ (?: (?&IPV4) | (?&IPV6) ) \\] )"
end

module PortRegexes
  # Number between 1 and 65535, with lookahead at the end so that we don't match "6789" in the string "67890",
  # and in turn we don't eventually match "http://host:6789" in "http://host:67890". */
  N_1_65535 = "(?x: (?: [1-9][0-9]{0,3} | [1-5][0-9]{4} | 6[0-4][0-9]{3} | 65[0-4][0-9]{2} | 655[0-2][0-9] | 6553[0-5] ) (?! [0-9] ) )"
  # Optional colon-prefixed port, e.g. ":1080", "" */
  PORT = "(?x: \\:#{N_1_65535} )?"
end

module PathRegexes
  # Omit the parentheses
  PATHCHARS_CLASS = "[-[:alnum:]\\Q_$.+!*,:;@&=?/~#|%\\E]"
  # Chars to end a URL
  PATHTERM_CLASS = "[-[:alnum:]\\Q_$+*:@&=/~#|%\\E]"
  # Recursive definition of PATH that allows parentheses and square brackets only if balanced, see bug 763980.
  PATH_INNER_DEF = "(?(DEFINE)(?<PATH_INNER>(?x: (?: #{PATHCHARS_CLASS}* (?: \\( (?&PATH_INNER) \\) | \\[ (?&PATH_INNER) \\] ) )* #{PATHCHARS_CLASS}* )))"
  #                "(?(DEFINE)(?<PATH_INNER>(?x: (?: " PATHCHARS_CLASS"* \\( (?&PATH_INNER) \\) )* " PATHCHARS_CLASS "* )))"
  # Same as above, but the last character (if exists and is not a parenthesis) must be from PATHTERM_CLASS.
  PATH_DEF = "(?(DEFINE)(?<PATH>(?x: (?: #{PATHCHARS_CLASS}* (?: \\( (?&PATH_INNER) \\) | \\[ (?&PATH_INNER) \\] ) )* (?: #{PATHCHARS_CLASS}* #{PATHTERM_CLASS} )? )))"
  URLPATH = "(?x: /(?&PATH) )?"
  VOIP_PATH = "(?x: [;?](?&PATH) )?"
end

module ColorRegexes
HEX_CLASS = "[a-fA-F0-9]"
# /*http://www.regular-expressions.info/numericranges.html*/
UINT8_CLASS = "\\b([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\\b"
PERCENT_CLASS = "(0{0,2}[0-9]\\s*\\%|0?[1-9][0-9]\\s*\\%|100\\s*\\%)"
HEX_COLOR  = "#(#{HEX_CLASS}{16}|#{HEX_CLASS}{12}|#{HEX_CLASS}{9}|#{HEX_CLASS}{8}|#{HEX_CLASS}{6}|#{HEX_CLASS}{4}|#{HEX_CLASS}{3})"
RGB_COLOR = "rgb\\s*\\(\\s*#{UINT8_CLASS}\\s*\\,\\s*#{UINT8_CLASS}\\s*\\,\\s*#{UINT8_CLASS}\\s*\\)"
RGBPERC_COLOR = "rgb\\s*\\(\\s*#{PERCENT_CLASS}\\s*\\,\\s*#{PERCENT_CLASS}\\s*\\,\\s*#{PERCENT_CLASS}\\s*\\)"
RGBA_COLOR = "rgba\\s*\\(\\s*#{UINT8_CLASS}\\s*\\,\\s*#{UINT8_CLASS}\\s*\\,\\s*#{UINT8_CLASS}\\s*\\,\\s*[0-1](\\.[0-9]*)?\\s*\\)"
RGBAPERC_COLOR = "rgba\\s*\\(\\s*#{PERCENT_CLASS}\\s*\\,\\s*#{PERCENT_CLASS}\\s*\\,\\s*#{PERCENT_CLASS}\\s*\\,\\s*[0-1](\\.[0-9]*)?\\s*\\)"
include RgbNames
CSS_COLORS = "#{HEX_COLOR}|#{RGB_COLOR}|#{RGBPERC_COLOR}|#{RGBA_COLOR}|#{RGBAPERC_COLOR}|#{COLOR_NAMES}"
end

module TopinambourRegex
  SCHEME = "(?ix: news | telnet | nntp | https? | ftps? | sftp | webcal )"
  include UserPassRegexes
  include IpRegexes
  include HostnameRegexes
  include PortRegexes
  include PathRegexes

  # Now let's put these fragments together */
  DEFS = "#{IP_DEF}#{PATH_INNER_DEF}#{PATH_DEF}"
  REGEX_URL_AS_IS = "#{DEFS}#{SCHEME}://#{USERPASS}#{URL_HOST}#{PORT}#{URLPATH}"
  # TODO: also support file:/etc/passwd */
  REGEX_URL_FILE = "#{DEFS}(?ix: file:/ (?: / (?: #{HOSTNAME1} )? / )? (?! / ) )(?&PATH)"
  # Lookbehind so that we don't catch "abc.www.foo.bar", bug 739757.
  # Lookahead for www/ftp for convenience (so that we can reuse HOSTNAME1). */
  REGEX_URL_HTTP = "#{DEFS}(?<!(?:#{HOSTNAMESEGMENTCHARS_CLASS}|[.]))(?=(?i:www|ftp))#{HOSTNAME1}#{PORT}#{URLPATH}"
  REGEX_URL_VOIP = "#{DEFS}(?i:h323:|sips?:)#{USERPASS}#{URL_HOST}#{PORT}#{VOIP_PATH}"
  REGEX_EMAIL = "#{DEFS}(?i:mailto:)?#{USER}@#{EMAIL_HOST}"
  REGEX_NEWS_MAN = "(?i:news:|man:|info:)[-[:alnum:]\\Q^_{|}~!\"#$%&'()*+,./;:=?`\\E]+"
  include ColorRegexes
end

module Pcre2
  # PCRE2_UTF | PCRE2_NO_UTF_CHECK | PCRE2_MULTILINE
  UTF = "0x00080000".to_i(16)
  NO_UTF_CHECK = "0x40000000".to_i(16)
  MULTILINE = "0x00000400".to_i(16)
  ALL_FLAGS = UTF | NO_UTF_CHECK | MULTILINE

end
