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
            
            DataSet ds = AddUserName("toddles");
            foreach (DataRow aRow in ds.Tables[0].Rows)
            {
                Console.WriteLine("Log in Status = " + aRow["Message"]);
            }
            

            Console.WriteLine();
            Console.ReadLine();
        }

        private static DataSet AddUserName(string pUserName)
        {
            String connectionString = "Server=localhost;Port=3306;Database=sapodb;Uid=sapo;password=53211;";
            MySqlConnection mySqlConnection = new MySqlConnection(connectionString);
            List<MySqlParameter> p = new List<MySqlParameter>();
            var aP = new MySqlParameter("@UserName", MySqlDbType.VarChar, 50);
            aP.Value = pUserName;
            p.Add(aP);


            var aDataSet = MySqlHelper.ExecuteDataset(mySqlConnection, "AddUserName(@UserName)", p.ToArray());


            return aDataSet;
        }
    

       
    }
}
