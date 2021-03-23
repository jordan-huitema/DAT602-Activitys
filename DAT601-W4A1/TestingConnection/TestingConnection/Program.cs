using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using MySql.Data.MySqlClient;

namespace TestingConnection
{
    class Program
    {
        static void Main(string[] args)
        {
            // GetDataUsingQuery();
            Console.WriteLine("Enter User Name");
            string loginName = Console.ReadLine();

            DataSet ds = Query(loginName, "AddUserName(@UserName)");
            foreach (DataRow aRow in ds.Tables[0].Rows)
            {
                Console.WriteLine("Log in Status = " + aRow["Message"]);
            }

            Console.WriteLine("Press any key to continue");
            Console.ReadLine();

            ds = Query(null, "GetAllPlayers()");
            foreach (DataRow aRow in ds.Tables[0].Rows)
            {
                Console.WriteLine("List of Users:");
                Console.WriteLine(aRow["UserName"]);
            }

            Console.WriteLine("Press any key to Quit");
            Console.ReadLine();

            ds = Query(loginName, "PlayerQuit(@UserName)");
            foreach (DataRow aRow in ds.Tables[0].Rows)
            {
                Console.WriteLine(loginName + aRow["Message"]);
            }
        }

        private static DataSet Query(string pUserName, string command)
        {
            String connectionString = "Server=localhost;Port=3306;Database=sapodb;Uid=sapo;password=53211;";
            MySqlConnection mySqlConnection = new MySqlConnection(connectionString);
            List<MySqlParameter> p = new List<MySqlParameter>();
            var aP = new MySqlParameter("@UserName", MySqlDbType.VarChar, 50);
            aP.Value = pUserName;
            p.Add(aP);


            var aDataSet = MySqlHelper.ExecuteDataset(mySqlConnection, command, p.ToArray());


            return aDataSet;
        }



    }
}
