=begin
= ABNF

== Example

  # IPv6 [RFC2373]
  p %r{\A#{ABNF.regexp <<'End'}\z}o =~ "FEDC:BA98:7654:3210:FEDC:BA98:7654:3210"
    IPv6address = hexpart [ ":" IPv4address ]
    IPv4address = 1*3DIGIT "." 1*3DIGIT "." 1*3DIGIT "." 1*3DIGIT
    hexpart = hexseq | hexseq "::" [ hexseq ] | "::" [ hexseq ]
    hexseq  = hex4 *( ":" hex4)
    hex4    = 1*4HEXDIG
  End

  Note that this is wrong because it doesn't match to "::13.1.68.3".

  # URI-reference [RFC2396]
  p %r{\A#{ABNF.regexp <<'End'}\z}o
        URI-reference = [ absoluteURI | relativeURI ] [ "#" fragment ]
        ...
        digit    = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" |
                   "8" | "9"
  End

== ABNF class

=== class methods

--- regexp(abnf_description[, start_symbol])
    converts ((|abnf_description|)) to a regular expression corresponding with
    ((|start_symbol|)).

    If ((|start_symbol|)) is not specified, first symbol in
    ((|abnf_description|)) is used.

=end

require 'abnf/corerules'
require 'abnf/regexp'

module ABNF
  def ABNF.regexp(desc, name=nil)
    Regexp.compile ABNF.regexp_object(desc, name).to_s
  end

  def ABNF.regexp_object(desc, name=nil)
    grammar = Grammar.new
    grammar.import(CoreRules)
    first = Parser.new(grammar).parse(desc)
    raise StandardError.new("no rule defined") if first.nil?
    name ||= first
    grammar.regexp(name)
  end
end

if $0 == __FILE__
  # IPv6 [RFC2373]
  # Note that this ABNF description is wrong: e.g. it doesn't match to "::13.1.68.3".
  p %r{\A#{ABNF.regexp <<-'End'}\z}o =~ "FEDC:BA98:7654:3210:FEDC:BA98:7654:3210"
    IPv6address = hexpart [ ":" IPv4address ]
    IPv4address = 1*3DIGIT "." 1*3DIGIT "." 1*3DIGIT "." 1*3DIGIT
    hexpart = hexseq | hexseq "::" [ hexseq ] | "::" [ hexseq ]
    hexseq  = hex4 *( ":" hex4)
    hex4    = 1*4HEXDIG
  End

  # URI-reference [RFC2396]
  ABNF.regexp_object(<<-'End').pretty_display
        URI-reference = [ absoluteURI | relativeURI ] [ "#" fragment ]
        absoluteURI   = scheme ":" ( hier_part | opaque_part )
        relativeURI   = ( net_path | abs_path | rel_path ) [ "?" query ]

        hier_part     = ( net_path | abs_path ) [ "?" query ]
        opaque_part   = uric_no_slash *uric

        uric_no_slash = escaped | unreserved | ";" | "?" | ":" | "@" |
                        "&" | "=" | "+" | "$" | ","

        net_path      = "//" authority [ abs_path ]
        abs_path      = "/"  path_segments
        rel_path      = rel_segment [ abs_path ]

        rel_segment   = 1*( escaped | unreserved |
                            ";" | "@" | "&" | "=" | "+" | "$" | "," )

        scheme        = alpha *( alpha | digit | "+" | "-" | "." )

        authority     = server | reg_name

        reg_name      = 1*( escaped | unreserved | "$" | "," |
                            ";" | ":" | "@" | "&" | "=" | "+" )

        server        = [ [ userinfo "@" ] hostport ]
        userinfo      = *( escaped | unreserved |
                           ";" | ":" | "&" | "=" | "+" | "$" | "," )

        hostport      = host [ ":" port ]
        host          = hostname | IPv4address
        hostname      = *( domainlabel "." ) toplabel [ "." ]
        domainlabel   = alphanum | alphanum *( alphanum | "-" ) alphanum
        toplabel      = alpha | alpha *( alphanum | "-" ) alphanum
        IPv4address   = 1*digit "." 1*digit "." 1*digit "." 1*digit
        port          = *digit

        path          = [ abs_path | opaque_part ]
        path_segments = segment *( "/" segment )
        segment       = *pchar *( ";" param )
        param         = *pchar
        pchar         = escaped | unreserved |
                        ":" | "@" | "&" | "=" | "+" | "$" | ","

        query         = *uric

        fragment      = *uric

        uric          = reserved | unreserved | escaped
        reserved      = ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" |
                        "$" | ","
        unreserved    = alphanum | mark
        mark          = "-" | "_" | "." | "!" | "~" | "*" | "'" |
                        "(" | ")"

        escaped       = "%" hex hex
        hex           = digit | "A" | "B" | "C" | "D" | "E" | "F" |
                                "a" | "b" | "c" | "d" | "e" | "f"

        alphanum      = alpha | digit
        alpha         = lowalpha | upalpha

        lowalpha = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" |
                   "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" |
                   "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z"
        upalpha  = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" |
                   "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" |
                   "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z"
        digit    = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" |
                   "8" | "9"
  End
end