<%@ Page Title="塔科夫交易行 - 身份验证" Language="C#" AutoEventWireup="true" CodeBehind="Auth.aspx.cs" Inherits="DeltaTradeHub.Auth" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>登录 / 注册 | 塔科夫交易行</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script src="Scripts/bootstrap.bundle.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            min-height: 100vh;
            background-image: url('img/2.png');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            font-family: 'Segoe UI', 'Poppins', system-ui, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }
        body::after {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.55);
            z-index: 0;
        }
        .flip-container {
            perspective: 1500px;
            width: 480px;
            max-width: 90%;
            margin: 2rem auto;
            position: relative;
            z-index: 1;
        }
        .flipper {
            position: relative;
            width: 100%;
            transition: transform 0.6s cubic-bezier(0.23, 1, 0.32, 1);
            transform-style: preserve-3d;
        }
        .flip-container.flip .flipper { transform: rotateY(180deg); }
        .front, .back {
            position: relative;
            width: 100%;
            backface-visibility: hidden;
            background: rgba(10, 30, 32, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 2rem;
            padding: 2rem 2rem 2.2rem;
            box-shadow: 0 30px 50px rgba(0, 0, 0, 0.6), 0 0 0 1px rgba(85, 139, 47, 0.3);
        }
        .front { transform: rotateY(0deg); }
        .back { transform: rotateY(180deg); position: absolute; top: 0; left: 0; }
        .brand { text-align: center; margin-bottom: 1.8rem; }
        .brand h1 {
            font-size: 2rem;
            font-weight: 700;
            background: linear-gradient(135deg, #D4AF37, #7CB342);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }
        .brand p { color: #aad0d0; font-size: 0.85rem; }
        .icon-img { width: 55px; margin-bottom: 8px; filter: drop-shadow(0 0 8px #7cb342); }
        .form-floating { margin-bottom: 1.2rem; }
        .form-floating input {
            background-color: #0c2226;
            border: 1px solid #2b6f6f;
            border-radius: 12px;
            color: #f0f0f0;
        }
        .form-floating input:focus {
            background-color: #0f2c30;
            border-color: #7cb342;
            box-shadow: 0 0 0 0.2rem rgba(124, 179, 66, 0.25);
            color: white;
        }
        .form-floating label { color: #9fc9ce; }
        .btn-action {
            background: linear-gradient(95deg, #7cb342, #558b2f);
            border: none;
            padding: 12px;
            font-weight: bold;
            font-size: 1rem;
            border-radius: 40px;
            width: 100%;
            color: white;
            transition: all 0.2s;
            margin-top: 0.5rem;
        }
        .btn-action:hover { transform: scale(1.02); filter: brightness(1.05); }
        .link-helper { text-align: center; margin-top: 1.5rem; color: #bdd4d4; }
        .link-helper a { color: #f5c542; text-decoration: none; font-weight: 600; }
        .alert-custom {
            background: rgba(220,53,69,0.2);
            border-left: 4px solid #f66;
            padding: 8px 15px;
            border-radius: 20px;
            margin-bottom: 1rem;
            color: #ffe1e1;
        }
        .alert-success-custom {
            background: rgba(40,167,69,0.2);
            border-left: 4px solid #28a745;
            padding: 8px 15px;
            border-radius: 20px;
            margin-bottom: 1rem;
            color: #c3ffc3;
        }
        .password-strength { font-size: 0.7rem; margin-top: -8px; margin-bottom: 8px; padding-left: 8px; }
        footer { text-align: center; margin-top: 20px; color: #3d6b6b; font-size: 0.7rem; position: relative; z-index: 1; }
    </style>
</head>
<body>
    <form id="formAuth" runat="server">
        <div class="flip-container" id="flipContainer">
            <div class="flipper">
                <!-- 正面：登录 -->
                <div class="front">
                    <div class="brand">
                        <img src="img/3.jpg" class="icon-img" alt="Logo" />
                        <h1>塔科夫交易行</h1>
                        <p>黑市军火商 · 顶级装备</p>
                    </div>
                    <asp:PlaceHolder ID="phLoginError" runat="server" Visible="false">
                        <div class="alert-custom"><asp:Label ID="lblLoginError" runat="server"></asp:Label></div>
                    </asp:PlaceHolder>
                    <div class="form-floating">
                        <asp:TextBox ID="txtLoginUsername" runat="server" CssClass="form-control" placeholder="用户名" />
                        <label>⚡ 用户名</label>
                    </div>
                    <div class="form-floating">
                        <asp:TextBox ID="txtLoginPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="密码" />
                        <label>🔒 密码</label>
                    </div>
                    <div class="form-check mb-3">
                        <asp:CheckBox ID="chkRemember" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label text-light">记住我</label>
                    </div>
                    <asp:Button ID="btnLogin" runat="server" Text="进入黑市 →" CssClass="btn-action" OnClick="btnLogin_Click" />
                    <div class="link-helper">还没有账号？ <a href="#" id="showRegisterBtn">立即注册</a></div>
                </div>

                <!-- 背面：注册 -->
                <div class="back">
                    <div class="brand">
                        <img src="img/3.jpg" class="icon-img" alt="Logo" />
                        <h1>加入塔科夫</h1>
                        <p>成为精英PMC</p>
                    </div>
                    <asp:PlaceHolder ID="phRegMessage" runat="server" Visible="false">
                        <div id="regMsgPanel" runat="server" class="alert-custom">
                            <asp:Label ID="lblRegMessage" runat="server"></asp:Label>
                        </div>
                    </asp:PlaceHolder>
                    <div class="form-floating">
                        <asp:TextBox ID="txtRegUsername" runat="server" CssClass="form-control" placeholder="用户名" />
                        <label>👤 用户名 (3-20字符)</label>
                    </div>
                    <div class="form-floating">
                        <asp:TextBox ID="txtRegEmail" runat="server" CssClass="form-control" placeholder="电子邮箱" />
                        <label>📧 电子邮箱</label>
                    </div>
                    <div class="form-floating">
                        <asp:TextBox ID="txtRegPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="密码" />
                        <label>🔐 密码 (至少6位)</label>
                    </div>
                    <div class="form-floating">
                        <asp:TextBox ID="txtRegConfirmPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="确认密码" />
                        <label>✓ 确认密码</label>
                    </div>
                    <asp:Button ID="btnRegister" runat="server" Text="注册并进入黑市 →" CssClass="btn-action" OnClick="btnRegister_Click" />
                    <div class="link-helper">已有账号？ <a href="#" id="showLoginBtn">返回登录</a></div>
                </div>
            </div>
        </div>
        <footer>NIJITA</footer>
    </form>

    <script type="text/javascript">
        $(function () {
            var $container = $('#flipContainer');
            $('#showRegisterBtn').click(function (e) { e.preventDefault(); $container.addClass('flip'); });
            $('#showLoginBtn').click(function (e) { e.preventDefault(); $container.removeClass('flip'); });

            var urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('regSuccess') === '1') {
                $container.removeClass('flip');
                var regUser = urlParams.get('user');
                if (regUser) $('#<%= txtLoginUsername.ClientID %>').val(regUser);
                setTimeout(function () { alert('注册成功！请登录'); }, 100);
            }

            // 密码强度提示
            $('#<%= txtRegPassword.ClientID %>').on('keyup', function () {
                let val = $(this).val();
                let strength = '';
                if (val.length >= 8 && /[A-Z]/.test(val) && /[0-9]/.test(val)) strength = '强';
                else if (val.length >= 6) strength = '中';
                else strength = '弱';
                if (val.length > 0) {
                    if ($('.strength-tip').length === 0)
                        $(this).after('<div class="password-strength strength-tip">密码强度: <span id="strengthVal"></span></div>');
                    $('#strengthVal').text(strength).css('color', strength === '强' ? '#7cb342' : (strength === '中' ? '#f7b32b' : '#f66'));
                } else $('.strength-tip').remove();
            });
        });
    </script>
</body>
</html>