<?php
// Init
error_reporting(NULL);
ob_start();
session_start();
$TAB = 'FIREWALL';

// Main include
include($_SERVER['DOCUMENT_ROOT']."/inc/main.php");

// Check user
if ($_SESSION['user'] != 'admin') {
    header("Location: /list/user");
    exit;
}

// Check POST request
if (!empty($_POST['ok'])) {

    // Check empty fields
    if (empty($_POST['v_action'])) $errors[] = __('action');
    if (empty($_POST['v_protocol'])) $errors[] = __('protocol');
    if (empty($_POST['v_port'])) $errors[] = __('port');
    if (empty($_POST['v_ip'])) $errors[] = __('ip address');
    if (!empty($errors[0])) {
        foreach ($errors as $i => $error) {
            if ( $i == 0 ) {
                $error_msg = $error;
            } else {
                $error_msg = $error_msg.", ".$error;
            }
        }
        $_SESSION['error_msg'] = __('Field "%s" can not be blank.',$error_msg);
    }

    // Protect input
    $v_action = escapeshellarg($_POST['v_action']);
    $v_protocol = escapeshellarg($_POST['v_protocol']);
    $v_port = str_replace(" ",",", $_POST['v_port']);
    $v_port = preg_replace('/\,+/', ',', $v_port);
    $v_port = trim($v_port, ",");
    $v_port = escapeshellarg($v_port);
    $v_ip = escapeshellarg($_POST['v_ip']);
    $v_comment = escapeshellarg($_POST['v_comment']);

    // Add firewall rule
    if (empty($_SESSION['error_msg'])) {
        exec (VESTA_CMD."v-add-firewall-rule ".$v_action." ".$v_ip." ".$v_port." ".$v_protocol." ".$v_comment, $output, $return_var);
        check_return_code($return_var,$output);
        unset($output);
    }

    // Flush field values on success
    if (empty($_SESSION['error_msg'])) {
        $_SESSION['ok_msg'] = __('RULE_CREATED_OK');
        unset($v_port);
        unset($v_ip);
        unset($v_comment);
    }
}

// Header
include($_SERVER['DOCUMENT_ROOT'].'/templates/header.html');

// Panel
top_panel($user,$TAB);

// Display body
include($_SERVER['DOCUMENT_ROOT'].'/templates/admin/add_firewall.html');

// Flush session messages
unset($_SESSION['error_msg']);
unset($_SESSION['ok_msg']);

// Footer
include($_SERVER['DOCUMENT_ROOT'].'/templates/footer.html');
