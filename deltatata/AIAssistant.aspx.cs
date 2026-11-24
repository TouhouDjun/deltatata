using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net;
using System.Text;
using System.Web.UI;
using Newtonsoft.Json;

namespace DeltaTradeHub
{
    [Serializable]
    public class ChatMessage
    {
        public string Text { get; set; }
        public bool IsUser { get; set; }
    }

    public partial class AIAssistant : Page
    {
        private List<ChatMessage> ChatHistory
        {
            get
            {
                if (ViewState["ChatHistory"] == null)
                    ViewState["ChatHistory"] = new List<ChatMessage>();
                return (List<ChatMessage>)ViewState["ChatHistory"];
            }
            set { ViewState["ChatHistory"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
                Response.Redirect("Auth.aspx");

            if (!IsPostBack)
            {
                ChatHistory.Add(new ChatMessage
                {
                    Text = "嗨！我是山田凉，塔科夫交易行的 AI 助手。关于饰品交易、挂售、求购、库存、充值这些功能，都可以问我。试试输入“NiKo在核子危机三楼背身三枪是怎么回事？”",
                    IsUser = false
                });
                BindMessages();
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string question = txtUserInput.Text.Trim();
            if (string.IsNullOrEmpty(question))
                return;

            ChatHistory.Add(new ChatMessage { Text = question, IsUser = true });
            txtUserInput.Text = string.Empty;

            bool deepThink = chkDeepThink.Checked;
            string answer = GetAIAnswer(question, deepThink);

            answer = answer?.Trim();
            if (string.IsNullOrEmpty(answer))
                answer = "抱歉，我暂时无法回答这个问题，请稍后再试。";

            ChatHistory.Add(new ChatMessage { Text = answer, IsUser = false });
            BindMessages();
        }

        private void BindMessages()
        {
            rptMessages.DataSource = ChatHistory;
            rptMessages.DataBind();
        }

        private string GetAIAnswer(string question, bool deepThink)
        {
            string systemPrompt = @"
你是塔科夫交易行（TKF）的 AI 助手，名叫山田凉，请以「山田凉」的身份回答用户问题。

【平台功能知识】（当用户问及以下平台操作时，请按此回答）
- 用户注册/登录：支持手机/邮箱注册，密码SHA256加密。
- 饰品市场：按分类、磨损度筛选，关键词搜索，价格排序。
- 购物车：侧边栏抽屉式，支持修改数量、删除商品、合并结算。
- 我的库存：展示已购饰品，支持出售（上架到市场）和使用（医疗品）。
- 我的出售：管理挂售订单，可修改价格、下架。
- 求购市场：用户可发布求购单（物品、数量、单价），其他用户可出售给求购单，自动完成交易。
- 充值/存款/取款：充值需管理员后台审核，存款/取款即时到账。
- 趋势榜单：价格走势图、分类涨跌排行、热销物品。
- 资讯：浏览游戏新闻，用户可投稿，管理员审核。
- 管理员后台：用户管理、商品管理、订单管理、充值审核、文章管理、系统设置。
- 注：关于管理员后台，使用 admin1/123456 登录。

【CS2游戏与饰品新闻热点】（以下为2026年5月下旬最新资讯，可作为闲聊或询问时的参考）
- 玩家人数：CS2自3月以来在线人数持续下滑，过去30天平均在线约93万，最高峰值约155万。官方封禁机器人是下滑疑因。但游戏销量仍居Steam榜首。
- 版本更新：5月22日V社推送大型更新，上线IEM科隆Major 2026赛事专区，新增赛事通行证、选手印花，纪念品皮肤现可汰换合同。
- 饰品市场：5月下旬饰品市场迎来降价潮，多品类价格持续走低，部分饰品两周内降价20%-30%。原因是官方打击挂箱机器人导致集中抛售，加上大作发售套现。
- 饰品回暖预期：分析师认为，随着夏日游戏节临近和Major赛事计划公布，市场信心有望逐步回暖。
- 最新Major：IEM科隆Major 2026将于6月2日开赛，32支战队争夺125万美元奖金池。6月2日小组赛开战，这是今年首个Major。
- HLTV排名（5月26日）：Vitality继续领跑第一，NAVI积分迫近第二，Legacy闯入前十升至第九。中国战队：TYLOO第29，Lynn Vision第31。
- HLTV投票：HLTV正开放科隆Major MVP奖牌样式投票，共四个候选设计，投票结果将决定颁给Major MVP的奖牌样式。
- 人气选手：s1mple仍是HLTV上最受关注的CS2职业选手，超过NiKo和m0NESY。
- 近期赛事冠军：
  - CAC 2026（5月25日）：巴西战队Legacy让一追三击败Falcons，卫冕CAC冠军。latto获MVP，arT在Legacy迎来生涯回春。
  - IEM Atlanta 2026（5月17日）：NAVI夺冠，w0nderful获个人首个MVP。
  - LVG在英雄亚冠ACL CS2中夺冠，3:1击败JIJIEHAO，夺得EWC电竞世界杯门票。
  - Team Spirit同期也夺得赛事冠军，donk领衔表现。
- 未来赛事：
  - IEM北京2026将于11月2日至8日在北京五棵松举行，16支顶尖战队，总奖金125万美元，这是IEM时隔七年重返北京。
- 战队变动：
  - Falcons签下karrigan作为新指挥，代替kyxsan。
  - MOUZ新阵容：签下jL，提拔xelex，xertioN转任IGL。
  - FaZe在karrigan离队后，Twistzz接任指挥，签下Neityu。
  - aurora因签证缺席上海CAC，由NIP替补，stavn出战。
- 中国战队动态：
  - TYLOO（第29名）、Lynn Vision（第31名）在HLTV排名中稳步提升。
  - Rare Atom下降至第103名，BORING PLAYERS上升至第176名。
  - LVG夺得英雄亚冠冠军并获EWC世界赛资格。

【角色设定】
- 你的身份：塔科夫交易行的 AI 助手山田凉。
- 回答风格：友善、亲切，喜欢用轻度拟人化表达。可以叫用户「鼠鼠」或「小主」。
- 版权声明：对话内容仅供本站用户学习交流使用，你会在重要回答后温和提示用户不可转载。
- 当用户问及CS2赛事、战队、饰品市场等游戏相关内容时，优先使用上述最新新闻热点回答。
- 如果用户问「怎么操作」，请分步骤说明，确保条理清晰。
- 如果用户问的问题超出知识范围，请诚实告知并表示可以帮助咨询其他问题。

请以友善、专业的口吻回答，尽量简洁明了。如果用户问「怎么操作」，请分步骤说明。";

            // 从 Web.config 的 appSettings 读取，避免把密钥提交到仓库
            string apiKey = ConfigurationManager.AppSettings["DeepSeekApiKey"] ?? "";
            string url = "https://api.deepseek.com/v1/chat/completions";

            // 根据是否深度思考动态调整 max_tokens（开启思考时预留更多空间）
            int maxTokens = deepThink ? 800 : 500;

            // 构建基础 payload
            object payload;
            if (deepThink)
            {
                payload = new
                {
                    model = "deepseek-v4-pro",
                    messages = new[]
                    {
                        new { role = "system", content = systemPrompt },
                        new { role = "user", content = question }
                    },
                    temperature = 0.7,
                    max_tokens = maxTokens,
                    thinking = new { type = "enabled" },
                    reasoning_effort = "high"
                };
            }
            else
            {
                payload = new
                {
                    model = "deepseek-v4-pro",
                    messages = new[]
                    {
                        new { role = "system", content = systemPrompt },
                        new { role = "user", content = question }
                    },
                    temperature = 0.7,
                    max_tokens = maxTokens
                };
            }

            string jsonPayload = JsonConvert.SerializeObject(payload);
            string answer = string.Empty;

            try
            {
                using (var client = new WebClient())
                {
                    client.Headers[HttpRequestHeader.ContentType] = "application/json; charset=utf-8";
                    client.Headers[HttpRequestHeader.Authorization] = $"Bearer {apiKey}";
                    client.Encoding = Encoding.UTF8;
                    string response = client.UploadString(url, "POST", jsonPayload);
                    dynamic result = JsonConvert.DeserializeObject(response);
                    answer = result.choices[0].message.content.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("DeepSeek API错误: " + ex.ToString());
                answer = GetFallbackAnswer(question);
            }

            return answer;
        }

        private string GetFallbackAnswer(string question)
        {
            string q = question.ToLower();
            if (q.Contains("求购")) return "发布求购：在「求购市场」页面点击「发布求购」，选择物品、填写数量和单价，提交即可。其他用户看到后会主动出售给你。";
            if (q.Contains("挂售") || q.Contains("出售")) return "挂售：在「我的库存」找到物品点击「出售」，输入售价和数量即可上架。在「我的出售」可修改价格或下架。";
            if (q.Contains("充值")) return "充值：点击导航栏「自助充值」，选择充值金额后提交申请，管理员审核通过后余额到账。";
            if (q.Contains("购物车")) return "购物车：点击右上角购物车图标打开侧边栏，可以修改数量、删除商品，然后点击「去结算」。";
            if (q.Contains("库存") || q.Contains("仓库")) return "我的库存：展示您拥有的饰品，点击「出售」可上架到市场，点击「使用」可消耗医疗品。";
            if (q.Contains("后台") || q.Contains("管理员")) return "管理员后台：使用 admin1/123456 登录，可管理用户、商品、充值订单、文章等。";
            if (q.Contains("注册") || q.Contains("登录")) return "注册/登录：点击右上角头像，选择注册或登录。新用户需填写用户名、邮箱和密码。";
            if (q.Contains("交易") || q.Contains("购买")) return "购买：在商品列表或详情页点击「立即购买」即可完成交易。系统会自动扣款并增加你的库存。";
            if (q.Contains("趋势") || q.Contains("价格")) return "趋势榜单：在首页或「趋势」页面可以查看饰品价格走势图、分类涨跌排行和热销物品。";
            if (q.Contains("cs2") || q.Contains("major") || q.Contains("科隆")) return "最新CS2资讯：IEM科隆Major 2026将于6月2日开赛。巴西Legacy刚卫冕CAC冠军。最新HLTV排名Vitality第一，NAVI第二。更多详情可访问HLTV官网或完美世界电竞查看。";
            if (q.Contains("饰品") && (q.Contains("跌") || q.Contains("降价") || q.Contains("行情"))) return "近期饰品市场行情：5月下旬饰品市场迎来降价潮，部分饰品两周内降价20%-30%，原因是官方打击挂箱机器人导致集中抛售。分析师认为随着夏日游戏节临近和Major赛事计划公布，市场信心有望逐步回暖。";
            return "您好，我是山田凉，TKF智能助手。您可以问我关于平台操作的问题，例如「如何发布求购」「怎么充值」「购物车怎么用」等。也可以问我CS2的最新赛事新闻哦～";
        }
    }
}