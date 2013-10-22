# coding: utf-8

module IntroductionsMarkdown
  class << self
    def post_code
      <<-POST_CODE
较短的代码，可以用inline风格的markdown语法： `` `code` `` 。

较长的代码，可以用block风格的markdown语法： ```` ``` text ```` 。
本站对 ```` ``` ```` 之后的 **text** 进行了处理，你可以写明所要处理的语言，
如 `html` ， `ruby` （简写 `rb` 也可），也可以写明这段代码所在的文件，  
如 ```` ``` app/controllers/application_controller.rb ```` ，
系统根据后缀自动判断代码语言。高亮后的代码上方正中间会显示 `text => language` 样式的文字，
 **text** 为你在 ```` ``` ```` 后所输入的内容， **language** 为系统解析得到的语言。
如果 **text** 为空，或系统无法解析 **text** 的语言， **language** 将一律显示为 `text` 。

举例来说，如果这么来写： ```` ``` ```` ，之后在代码上方正中间会显示 `text => text` ；  
如果这么来写： ```` ``` ruby ```` ，之后在代码上方正中间会显示 `ruby => rb` ；  
如果这么来写： ```` ``` Gemfile ```` ，之后在代码上方正中间会显示 `Gemfile => text` ；  
如果这么来写： ```` ``` app/controllers/application_controller.rb ```` ，  
之后在代码上方正中间会显示 `app/controllers/application_controller.rb => rb` 。

除了以上两种写法，还有另外一种block风格的markdown语法，那就是把所有的代码全部缩进4个空格。
举例来说，就是 `....code` ，为了显示得清楚，这里用4个小数点代替4个空格。
这种写法的缺陷在于无法指定所使用的语言，所以代码将无法完成高亮，因此不推荐使用。
我能想到的一个应用场景是，用markdown语言来描述markdown的 ```` ``` language ```` 形式的语法：

    ``` markdown
    # Level 1 Header (H1)
    ## Level 2 Header (H2)
    ##### Level 5 Header (H5)

    Level 1 Header (H1)
    ===

    Level 2 Header (H2)
    ---

    ***

    | Tables         | Are            | Cool           |
    |:---------------|:--------------:|---------------:|
    | left aligned   | center aligned | right aligned  |
    | left aligned   | center aligned | right aligned  |
    | left aligned   | center aligned | right aligned  |
    ```
      POST_CODE
    end

    def post_image
      <<-POST_IMAGE
本站不提供图片存储功能，原因有三：

1. 若提供图片存储，将来用户增多后，存储要扩容，流量要扩容，我不能保证自己有足够的资金来维持。
   我也谢绝其他个人或公司的慷慨馈赠，这样一来，当推荐某公司某项服务时，由于没有利益关系，我可以大力推荐；
   或是产品做得不到位进行吐槽时，我也可以有一说一，没有人情的牵累。
2. 若提供图片存储，我必定会限制每个用户的初始存储容量，然后采用积分兑换容量的策略。
   当用户所剩容量不足以贴图，又没有足够积分来兑换容量时，为了贴图，他可能会
   1）删除旧图，为新图腾出空间 或 2）上传图片到提供外链服务的网站，然后用外链。
   前一种行为，会导致以前帖子里的图片失效，对浏览者来说，是一种不好的体验；
   后一种行为，虽对浏览者没什么影响，但对该用户而言，总归不是什么好的体验。
   所以，宁缺毋滥，我决定不提供图片存储。
3. 最重要的原因是：市场上有一些不仅好用而且还免费的外链服务。这里向大家强烈推荐 **Dropbox** ，
   **Dropbox** 是一种云存储服务，在Windows、Linux、Mac上都有相应的客户端，
   你可以访问[官方网站](https://www.dropbox.com/)（可能需要翻墙）来了解详情。当你拥有了 **Dropbox** 的帐号后，
   你可以访问[这里](https://www.dropbox.com/help/16/en)（可能需要翻墙）来了解如何进行图片外链。

贴图片的语法为 `![alt-text](http://YOUR-IMAGE-URL)` ，其中 **alt-text** 为你对该图片的描述，
可以省略不写；圆括号里面是图片的外链，写的时候可以省略协议头 `http://` 。
如果你已经在本站贴过链接或是视频，你会发现一旦少了协议头 `http://` ，系统就不能正确解析。
虽然贴图时可以省略协议头，但为了一致性，还是建议写上。
      POST_IMAGE
    end

    def post_video
      <<-POST_VIDEO
Markdown是支持 **inline HTML** 的，意味着，如果你将以下代码直接复制到markdown的文章中，你就嵌入了一个视频。

``` html
<iframe width="560" height="315" src="//www.youtube.com/embed/raiFrxbHxV0" frameborder="0" allowfullscreen></iframe>
```

但是，考虑到安全的因素，本站禁用了Markdown的这个功能。为了可以让你在markdown的文章中嵌入视频，
本站特别提供了另外一种写法： `!v[alt-text](http://EMBED-VIDEO-URL)` 。其中 **alt-text** 为你对该视频的描述，可以省略不写；
圆括号里面是视频的外链，注意请一定填写 `http://`，否则的话，系统将无法正确解析。

举例来说，下面分别是 [youtube](http://www.youtube.com/watch?v=raiFrxbHxV0)（需要翻墙）
和 [youku](http://v.youku.com/v_show/id_XNjIyMjIxMjgw.html) 上面的两个视频地址（请确定复制的是 **iframe** 类型的外链，因为本站只支持这种类型）

``` youtube.html
<iframe width="560" height="315" src="//www.youtube.com/embed/raiFrxbHxV0" frameborder="0" allowfullscreen></iframe>
```

``` youku.html
<iframe height=498 width=510 src="http://player.youku.com/embed/XNjIyMjIxMjgw" frameborder=0 allowfullscreen></iframe>
```

**youtube** 可以写成 `!v[](http://www.youtube.com/embed/raiFrxbHxV0)`  
**youku** 可以写成 `!v[](http://player.youku.com/embed/XNjIyMjIxMjgw)`  
请注意， **youtube** 的iframe地址中省略了 `http:` ，你需要手动加上去，否则系统无法正确解析。
      POST_VIDEO
    end
  end
end
