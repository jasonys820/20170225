<?php
$so = scws_new();
$so->set_charset('utf8');
$so->send_text("我是一个中国人,我会C++语言,我也有很多T恤衣服");
while ($tmp = $so->get_result())
{
print_r($tmp);
}
$so->close();
?>
