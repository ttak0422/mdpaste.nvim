-- nvim -l tests/run.lua
package.path = "lua/?.lua;lua/?/init.lua;" .. package.path
local md = require("mdpaste").html_to_md

local cases = {
  { '<a href="https://yahoo.co.jp">foo</a>', "[foo](https://yahoo.co.jp)" },
  { "<a href='https://x.com'><span>bar</span></a>", "[bar](https://x.com)" },
  { '<b>bold</b> and <a href="https://a.com"><b>link</b></a>', "**bold** and [**link**](https://a.com)" },
  { "<ul><li>one</li><li>two</li></ul>", "- one\n- two" },
  { "<h2>title</h2><p>body</p>", "## title\n\nbody" },
  { '<img src="https://a.com/x.png" alt="pic">', "![pic](https://a.com/x.png)" },
  { "a &amp; b &lt;c&gt; &#12354;", "a & b <c> あ" },
  { "plain <span>text</span>", "plain text" },
  { "<a>no href</a>", "no href" },
}

for _, c in ipairs(cases) do
  local got = md(c[1])
  assert(got == c[2], ("input: %s\nwant: %s\ngot:  %s"):format(c[1], c[2], got))
end
print(("%d cases OK"):format(#cases))
