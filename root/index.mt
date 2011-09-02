? local %_ = @_;
? my $board = $_{game}->board;
<!DOCTYPE html>
<html>
  <head>
    <style type="text/css">
.hex {
  cursor: pointer;
}
.hex:hover, .hex:focus {
  opacity: 0.3;
}
    </style>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
    <script type="text/javascript">
var Game = function () {
  this.color = '<?= $_{game}->current_color ?>';
};

var game = new Game();

$(function () {
  $('span.hex').click(function () {
    $.post(
      '/update',
      { x: $(this).attr('data-hex-x'), y: $(this).attr('data-hex-y'), color: game.color }
    ).done(
      function () {
        location.reload();
      }
    );
  });
});
    </script>
  </head>
  <body>
    <h1>Euler Getter</h1>
    <div id="board" style="font-size: 100px; line-height: 70px; letter-spacing: 0">
? for my $y (0 .. $board->size) {
    <div style="margin-left: <?= ($board->size - $y) * 50 + 50 ?>px">
?   for my $x (0 .. $board->size) {
?     my $hex = $board->hex_at($x, $y);
      <span style="color: <?= $hex->color || 'default' ?>; position: relative" class="hex" data-hex-x="<?= $x ?>" data-hex-y="<?= $y ?>" tabindex="0">
        &#x2B21;
        <span style="left: 0; position: absolute; font-size: 10px; text-shadow: 1px 1px white"><?= $hex ?></span>
      </span>
?   }
    </div>
? }
    </div>

    <table>
      <tbody>
        <tr>
          <th>red</th><th>blue</th>
        </tr>
        <tr>
          <td><?= $_{game}->euler_score_of_color('red') ?></td>
          <td><?= $_{game}->euler_score_of_color('blue') ?></td>
        </tr>
      </tbody>
    </table>
  </body>
</html>
