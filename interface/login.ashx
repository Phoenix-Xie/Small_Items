<%@ WebHandler Language="C#" Class="login" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.Collections;
using System.Data.SqlClient;
using System.Data;

public class login : IHttpHandler ,IRequiresSessionState{
    public void ProcessRequest(HttpContext context)
    {
        string usr, pwd, mode;
        mode = context.Request.QueryString["mode"].ToString();
        pwd = context.Request.QueryString["pwd"].ToString();
        usr = context.Request.QueryString["usr"].ToString();

        if (Test(pwd) != null)
        {
            context.Response.Write("密码" + Test(pwd));
        }
        else if (Test(usr) != null)
        {
            context.Response.Write("密码" + Test(pwd));
        }
        else
        {
            if (mode == "sign")
            {
                if(TestExist(usr))
                {
                    context.Response.Write("该用户名已存在");
                }
                else
                {
                    AddUser(usr, pwd);
                    context.Response.Write("注册成功");
                }
            }
            else if (mode == "login")
            {
                if(TestPwd(usr,pwd))
                {
                    HttpContext.Current.Session["UserName"] = usr;
                    context.Response.Write("登入成功");
                }
                else
                {
                    context.Response.Write("用户名或密码错误");
                }
            }
            else
            {
                context.Response.Write("请正确输入mode");
            }
        }
    }


    public string Test(string str)
    {
        if(str.Length > 20)
        {
            return "过长，不能超过20位";
        }
        else if(str == "")
        {
            return "不能为空";
        }
        else
        { return null; }
    }
    public bool IsReusable {
        get {
            return false;
        }
    }

    /// <summary>
    ///  (参数化，仅支持nvarchar类型)输入相关的sql语句，对相应数据库进行操作,无错误返回null，错误返回"数据库连接失败"
    /// </summary>
    public string AddUser(string UserName, string Pwd)
    {
        string sqlstring = "insert into users (UserName,Pwd) values (@UserName,@Pwd)";
        //Integrated Security 综合安全，集成安全
        string ConnectionString = @"server=DESKTOP-8ROVJ5G;Integrated Security=SSPI;database=interface";
        SqlConnection conn = new SqlConnection(ConnectionString);
        conn.Open();
        SqlCommand cmd = new SqlCommand();
        cmd.Connection = conn;
        cmd.CommandText = sqlstring;

        cmd.Parameters.Add("@UserName", SqlDbType.NVarChar);
        cmd.Parameters["@UserName"].Value = UserName;

        cmd.Parameters.Add("@Pwd", SqlDbType.NVarChar);
        cmd.Parameters["@Pwd"].Value = Pwd;
        cmd.ExecuteNonQuery();
        return null;
    }


    /// <summary>
    /// 存在返回true，否则返回false
    /// </summary>
    /// <param name="UserName"></param>
    /// <returns></returns>
    public bool TestExist(string UserName)
    {
        string sqlstr = "select * from users where UserName = @UserName";
        DataTable dt = Sql_Get_Datatable(sqlstr, "UserName", UserName);
        if(dt != null)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public bool TestPwd(string UserName, string Pwd)
    {
        string sqlstr = "select id from users where UserName = @UserName and Pwd = @Pwd";
        DataTable dt = Sql_Get_Datatable(sqlstr,"UserName",UserName,"Pwd",Pwd);
        if(dt != null)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public DataTable Sql_Get_Datatable(string sqlstring, params string[] items)
    {
        string ConnectionString = @"server=DESKTOP-8ROVJ5G;Integrated Security=SSPI;database=interface";
        SqlConnection conn = new SqlConnection(ConnectionString);
        conn.Open();
        SqlCommand cmd = new SqlCommand();     //生成新的连接            
        cmd.Connection = conn;
        cmd.CommandText = sqlstring;

        int i;
        for (i = 0; i < items.Length; i += 2)          //循环替换字符串中相应位置的参数，一个@something 对应一个 somenting
        {
            cmd.Parameters.Add("@" + items[i], SqlDbType.NVarChar);
            cmd.Parameters["@" + items[i]].Value = items[i + 1];
        }

        SqlDataAdapter da = new SqlDataAdapter(cmd); //注意，此处参数应为设置完成的cmd
        DataTable dt = new DataTable();
        da.Fill(dt);
        conn.Close();
        conn.Dispose();
        return dt;
    }
}