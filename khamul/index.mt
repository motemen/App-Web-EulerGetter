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
  </head>
  <body>
    index
    <form action="<?= K->req->script_name ?>/start" method="POST">
      <input type="number" name="size" value="4">
      <input type="submit" value="start">
    </form>
  </body>
</html>
