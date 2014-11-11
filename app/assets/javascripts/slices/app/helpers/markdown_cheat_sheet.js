// Adds a Markdown cheat sheet.
//
// Example:
//
//     {{markdownCheatSheet}}
//
Handlebars.registerHelper('markdownCheatSheet', function() {
  return new Handlebars.SafeString(
    '<div class="markdown-cheat-sheet">' +
      '<h4>Markdown Cheat Sheet</h4>' +
      '<div class="columns">' +
        '<div class="column">' +
          '<code># This is an &lt;h1&gt;</code>' +
          '<code>## This is an &lt;h2&gt;</code>' +
          '<code>###### This is an &lt;h6&gt;</code>' +
          '<code>*This text will be italic*</code>' +
          '<code>**This text will be bold**</code>' +
          '<code>*You **can** combine them*</code>' +
          '<code>[A Link](http://example.com/)</code>' +
          '<code>![An Image](http://example.com/example.jpg)</code>' +
        '</div>' +
        '<div class="column">' +
          '<code>' +
            '* An\n' +
            '* Unordered\n' +
            '* List' +
          '</code>' +
          '<code>' +
            '1. An\n' +
            '2. Ordered\n' +
            '3. List\n' +
            '   * With\n' +
            '   * Sub\n' +
            '   * List' +
          '</code>' +
          '<code>' +
            'The following is a blockquote:\n\n' +
            '> Sed posuere consectetur est at lobortis. Aenean lacinia\n' +
            '> bibendum nulla sed consectetur. Maecenas sed diam eget\n' +
            '> risus varius blandit sit amet non magna.' +
          '</code>' +
        '</div>' +
      '</div>' +
    '</div>'
  );
});

$(document).on('click', '.markdown-cheat-sheet h4', function() {
  $(this).parent().toggleClass('display');
});
