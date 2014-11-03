<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
 <head>
  <meta http-equiv="Content-Type" content="text/html;charset=iso-8859-1">
  <title>Colin O'Sullivan</title>
  <link rel="stylesheet" type="text/css" href="../style.css">
 </head>

 <body>

<?php
// In PHP versions earlier than 4.1.0, $HTTP_POST_FILES should be used instead
// of $_FILES.

$uploadfile = "applet/image.jpg";

if (move_uploaded_file($_FILES['userfile']['tmp_name'], $uploadfile)) {
    chmod($uploadfile, 0644);
    echo <<<END
<p>File uploaded successfully.</p>
<p>Continue <a href="applet/">here</a> to see resolution demo.</p>
END;
} else {
    echo <<<END
<p>Error uploading image. Max file size for uploaded images is 1MB.</p>
<p>Return <a href="index.html">here</a> to upload image.</p>
END;
}

?>

 </body>
</html>
