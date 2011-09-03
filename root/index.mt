? local %_ = @_;
? my $board = $_{game}->board;
<!DOCTYPE html>
<html>
  <head>
    <style type="text/css">
body {
  font-family: "Lucida Grande", sans-serif;
}
th {
  text-align: right;
}
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
};

var game = new Game();

$(function () {
  $('span.hex').click(function () {
    $.post(
      '/next',
      { x: $(this).attr('data-hex-x'), y: $(this).attr('data-hex-y'), game_id: $('#board').attr('data-game-id') }
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

    <p>You are <?= $_{color} || '(guest)' ?></p>

    <table>
      <tbody>
        <tr>
          <th>turn</th>
          <td>#<?= $_{game}->turn ?>, <?= $_{game}->current_color ?></td>
        </tr>
        <tr>
          <th>red</th>
          <td><?= $_{game}->euler_score_of_color('red') ?></td>
        </tr>
        <tr>
          <th>blue</th>
          <td><?= $_{game}->euler_score_of_color('blue') ?></td>
        </tr>
      </tbody>
    </table>

    <div id="board" data-game-id="<?= $_{game_id} ?>" style="font-size: 100px; line-height: 70px; letter-spacing: 0">
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

  </body>
</html>
