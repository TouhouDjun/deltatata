<%@ Page Title="AI智能助手 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AIAssistant.aspx.cs" Inherits="DeltaTradeHub.AIAssistant" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* 全局动画定义 */
        @keyframes bubble-in {
            from {
                transform: translateY(8px) scale(0.96);
                opacity: 0;
                filter: blur(1px);
            }
            to {
                transform: translateY(0) scale(1);
                opacity: 1;
                filter: none;
            }
        }

        @keyframes typing-dot {
            0%, 60%, 100% {
                opacity: 0.3;
                transform: scale(0.8);
            }
            30% {
                opacity: 1;
                transform: scale(1.2);
            }
        }

        .chat-container {
            max-width: 800px;
            margin: 30px auto;
            background: white;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            display: flex;
            flex-direction: column;
            height: 600px;
        }

        .chat-header {
            background: #ff7e00;
            color: white;
            padding: 16px 20px;
            font-weight: 700;
            font-size: 18px;
            text-align: left;
        }

        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: #f8fafc;
            text-align: left;
            display: flex;
            flex-direction: column;
        }

        .message {
            margin-bottom: 16px;
            display: flex;
            animation: bubble-in 320ms cubic-bezier(0.2, 0.7, 0.25, 1) both;
            align-items: flex-start;
        }

        .user-message {
            justify-content: flex-end;
        }

        .bot-message {
            justify-content: flex-start;
        }

        /* AI 头像样式 */
        .bot-avatar {
            flex-shrink: 0;
            width: 36px;
            height: 36px;
            margin-right: 12px;
        }

        .bot-avatar img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
        }

        .message-bubble {
            max-width: 70%;
            padding: 12px 18px;
            border-radius: 20px;
            font-size: 14px;
            line-height: 1.5;
            white-space: pre-wrap;
            word-break: break-word;
            text-align: left;
            text-indent: 0;
            margin: 0;
            position: relative;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }

        .user-message .message-bubble {
            background: #ff7e00;
            color: white;
            border-bottom-right-radius: 4px;
        }

        .bot-message .message-bubble {
            background: white;
            color: #1e293b;
            border: 1px solid #e2e8f0;
            border-bottom-left-radius: 4px;
        }

        /* 思考动画容器 */
        .typing-container {
            margin-bottom: 16px;
            display: flex;
            justify-content: flex-start;
            align-items: center;
        }

        .typing-container .bot-avatar {
            visibility: hidden; /* 占位保持对齐，不显示真实头像 */
        }

        .typing-indicator {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 12px 18px;
            background: white;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            border-bottom-left-radius: 4px;
            width: fit-content;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }

        .typing-indicator span {
            width: 8px;
            height: 8px;
            background: #94a3b8;
            border-radius: 50%;
            animation: typing-dot 1.4s infinite;
        }

        .typing-indicator span:nth-child(2) { animation-delay: 0.2s; }
        .typing-indicator span:nth-child(3) { animation-delay: 0.4s; }

        .chat-input-area {
            padding: 16px;
            background: white;
            border-top: 1px solid #edf2f7;
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .chat-input-area input {
            flex: 1;
            padding: 10px 16px;
            border: 1px solid #e2e8f0;
            border-radius: 40px;
            outline: none;
            transition: all 0.2s ease;
            font-size: 14px;
            background: white;
            text-align: left;
        }

        .chat-input-area input:focus {
            border-color: #ff7e00;
            box-shadow: 0 0 0 3px rgba(255, 126, 0, 0.1);
        }

        /* 深度思考开关样式 */
        .thinking-switch {
            display: flex;
            align-items: center;
            background: #f1f5f9;
            padding: 0 12px;
            border-radius: 40px;
            height: 42px;
            white-space: nowrap;
        }
        .thinking-switch label {
            margin: 0;
            font-size: 13px;
            color: #475569;
            cursor: pointer;
        }
        .thinking-switch input {
            margin-right: 6px;
            cursor: pointer;
            transform: scale(1.05);
            vertical-align: middle;
        }

        .chat-input-area button {
            background: #ff7e00;
            border: none;
            border-radius: 40px;
            padding: 0 28px;
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.15s ease;
            font-size: 14px;
            height: 42px;
            line-height: 42px;
            box-shadow: 0 2px 6px rgba(255, 126, 0, 0.2);
            transform: translateY(0);
        }

        .chat-input-area button:hover {
            background: #e67000;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(255, 126, 0, 0.25);
        }

        .chat-input-area button:active {
            background: #cc5c00;
            transform: translateY(1px) scale(0.97);
            box-shadow: 0 1px 3px rgba(255, 126, 0, 0.2);
        }

        .copyright {
            text-align: center;
            font-size: 11px;
            color: #aaa;
            padding: 8px 0;
            background: white;
            border-top: 1px solid #edf2f7;
        }
    </style>

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="chat-container">
                <div class="chat-header">
                    🤖 TKF智能助手 — 问询平台任何功能
                </div>
                <div class="chat-messages" id="chatMessages">
                    <asp:Repeater ID="rptMessages" runat="server">
                        <ItemTemplate>
                            <div class="message <%# Convert.ToBoolean(Eval("IsUser")) ? "user-message" : "bot-message" %>">
                                <%# !Convert.ToBoolean(Eval("IsUser")) ? "<div class='bot-avatar'><img src='img/ai.jpg' alt='山田凉' /></div>" : "" %>
                                <div class="message-bubble">
                                    <%# Eval("Text").ToString().Trim() %>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <!-- 思考动画 -->
                    <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="UpdatePanel1">
                        <ProgressTemplate>
                            <div class="typing-container">
                                <div class="bot-avatar"></div>
                                <div class="typing-indicator">
                                    <span></span>
                                    <span></span>
                                    <span></span>
                                </div>
                            </div>
                        </ProgressTemplate>
                    </asp:UpdateProgress>
                </div>
                <div class="chat-input-area">
                    <asp:TextBox ID="txtUserInput" runat="server" 
                                 placeholder="输入你的问题..."
                                 ClientIDMode="Static"
                                 onkeypress="if(event.keyCode==13) { document.getElementById('btnSend').click(); return false; }">
                    </asp:TextBox>
                    <div class="thinking-switch">
                        <asp:CheckBox ID="chkDeepThink" runat="server" Text="深度思考" 
                                      ToolTip="开启后回答更智能，但速度稍慢" 
                                      Checked="false" />
                    </div>
                    <asp:Button ID="btnSend" runat="server" 
                                Text="发送"
                                ClientIDMode="Static"
                                OnClick="btnSend_Click"
                                UseSubmitBehavior="false" />
                </div>
                <div class="copyright">
                    本对话内容仅供学习交流，请勿转载
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script>
        function scrollToBottom(force) {
            var chatDiv = document.getElementById('chatMessages');
            if (!chatDiv) return;
            chatDiv.scrollTop = chatDiv.scrollHeight;
            if (force === true) {
                setTimeout(function () {
                    if (chatDiv) chatDiv.scrollTop = chatDiv.scrollHeight;
                }, 80);
            }
        }

        window.addEventListener('load', function () {
            scrollToBottom(true);
            var input = document.getElementById('txtUserInput');
            if (input) input.focus();
        });

        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () {
                setTimeout(function () {
                    scrollToBottom(true);
                    var input = document.getElementById('txtUserInput');
                    if (input) input.focus();
                }, 150);
            });
        }

        var sendBtn = document.getElementById('btnSend');
        if (sendBtn) {
            sendBtn.addEventListener('click', function () {
                scrollToBottom(false);
            });
        }
    </script>
</asp:Content>