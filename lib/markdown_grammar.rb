module MarkdownGrammar
  class << self
    def headers
      <<-HEADERS
# Level 1 Header (H1)
## Level 2 Header (H2)
##### Level 5 Header (H5)

Level 1 Header (H1)
===

Level 2 Header (H2)
---
      HEADERS
    end

    def paragraphs
      <<-PARAGRAPHS
One or more consecutive lines of text
separated by one or more blank lines.

This is another paragraph.
      PARAGRAPHS
    end

    def line_breaks
      <<-LINE_BREAKS
To create a line break, end a line in a paragraph  
with two or more spaces.
      LINE_BREAKS
    end

    def horizontal_rule
      <<-HORIZONTAL_RULE
Three or more hyphens or asterisks or underscores

---

***

___
      HORIZONTAL_RULE
    end

    def emphasis
      <<-EMPHASIS
Emphasis, aka italics, with *asterisks* or _underscores_.

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this.~~
      EMPHASIS
    end

    def lists
      <<-LISTS
1. First ordered list item
2. Another item
  * Unordered sub-list.
1. Actual numbers don't matter, just that it's a number
  1. Ordered sub-list
4. And another item.

* Unordered list can use asterisks
- Or minuses
+ Or pluses
      LISTS
    end

    def code
      <<-'CODE'
`inline code`

``` ruby
def welcome(name)
  puts "hello, #{name}"
end
```

    /* you can indent four spaces to write your code */
    #include <stdio.h>

    int main(int argc, char *argv[])
    {
        puts("hello, world!");
        return 0;
    }
      CODE
    end

    def tables
      <<-TABLES
| Tables         | Are            | Cool           |
|:---------------|:--------------:|---------------:|
| left aligned   | center aligned | right aligned  |
| left aligned   | center aligned | right aligned  |
| left aligned   | center aligned | right aligned  |
      TABLES
    end

    def blockquotes
      <<-BLOCKQUOTES
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.
>> and you can quote another if you like
>>> or one more if it's really necessary.
      BLOCKQUOTES
    end

    def links
      "[WaterFlowsEast](http://www.waterflowseast.com)"
    end

    def images
      "![alt-text](http://www.waterflowseast.com/assets/waterflowseast.png)"
    end

    def videos
      <<-VIDEOS
!v[alt-text](http://www.youtube.com/embed/raiFrxbHxV0)

!v[alt-text](http://player.youku.com/embed/XNjIyMjIxMjgw)
      VIDEOS
    end
  end
end
