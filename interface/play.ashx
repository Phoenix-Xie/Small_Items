<%@ WebHandler Language="C#" Class="play" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.Data;
using System.Text;

public class play: IHttpHandler,IReadOnlySessionState {

    string UserName;
    public void ProcessRequest (HttpContext i) {

        if(!TestLogin())
        {
            i.Response.Write("登入后再玩耍~~");
        }
        else
        {
            string UserChoose = i.Request.Form["UserChoose"];
            if(!(UserChoose == "石头" || UserChoose == "布" || UserChoose == "剪刀"))
            {
                i.Response.Write("剪刀石头布就是剪刀石头布，不能耍赖出别的呦~");
            }
            else
            {
                Random ra = new Random();
                int computer = ra.Next(1, 4);
                int judgement;

                //1 石头， 2剪刀， 3布
                if(UserChoose == "石头")
                {
                    if(computer == 1)
                    {
                        judgement = 0;
                    }
                    else if(computer == 2)
                    {
                        judgement = 1;
                    }
                    else
                    {
                        judgement = -1;
                    }
                }
                else if(UserChoose == "剪刀")
                {
                    if(computer == 1)
                    {
                        judgement = -1;
                    }
                    else if(computer == 2)
                    {
                        judgement = 0;
                    }
                    else
                    {
                        judgement = 1;
                    }
                }
                else
                {
                    if(computer == 1)
                    {
                        judgement = 1;
                    }
                    else if(computer == 2)
                    {
                        judgement = -1;
                    }
                    else
                    {
                        judgement = 0;
                    }
                }
                string[] computer_s = { "石头", "剪刀", "布" };
                //1 石头， 2剪刀， 3布
                if(judgement == 1)
                {
                    i.Response.Write("电脑出" + computer_s[computer-1] + "，恭喜获胜");
                }
                else if(judgement == 0)
                {
                    i.Response.Write("电脑出" + computer_s[computer-1] + "，平局");
                }
                else
                {
                    i.Response.Write("电脑出" + computer_s[computer-1] + "，惨败");
                }
            }

        }

    }

    public bool IsReusable {
        get {
            return false;
        }
    }

    public bool TestLogin()
    {
        try
        {
            UserName =  HttpContext.Current.Session["UserName"].ToString();
            if(UserName != null)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        catch
        {
            return false;
        }
    }

}