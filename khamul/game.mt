? local %_ = @_;
? my $game = K->game;
? my $color = K->color;
? my $board = K->game->board;
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
? if ($color && $game->current_color eq $color) {

$(function () {
  $('span.hex').click(function () {
    $.post(
      '../next',
      { x: $(this).attr('data-hex-x'), y: $(this).attr('data-hex-y'), game_id: $('#board').attr('data-game-id') }
    ).done(
      function () {
        location.reload();
      }
    );
  });
});

? } else {

$(function () {
  $('<script/>').attr('src', '../reload.js?game_id=' + $('#board').attr('data-game-id')).appendTo(document.body);
});

? }

setInterval(
  function () {
    $.get(
      '../game.json?game_id=' + $('#board').attr('data-game-id')
    ).done(
      function (x) {
        if (x.time > $('#board').attr('data-game-time')) {
          location.reload();
        }
      }
    )
  },
  20 * 1000
);
    </script>
  </head>
  <body>
    <h1>Euler Getter</h1>

    <p>You are <?= $color || '(guest)' ?></p>

    <table>
      <tbody>
        <tr>
          <th>turn</th>
          <td>#<?= $game->turn ?>, <?= $game->current_color ?></td>
        </tr>
        <tr>
          <th>red</th>
          <td><?= $game->euler_score_of_color('red') ?></td>
        </tr>
        <tr>
          <th>blue</th>
          <td><?= $game->euler_score_of_color('blue') ?></td>
        </tr>
      </tbody>
    </table>

    <div id="board" data-game-id="<?= K->game_id ?>" data-game-time="<?= $_{time} ?>" style="font-size: 100px; line-height: 70px; letter-spacing: 0; width: <?= $board->size * 200 + 100 ?>px">
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
