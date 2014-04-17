<?php
function genlic($input) {
    $md5string = md5($input);
    $license = $input;
    for ($i = 0; $i < strlen($md5string)/2; $i++) {
        $dec = hexdec((substr($md5string, $i*2, 2)));
        if ($dec > 128) {
            $dec = -(256 - $dec);
        }
        $license .= $dec;
    }
    return $license;
}
?>
