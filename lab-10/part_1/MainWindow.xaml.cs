using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace lab10._1
{
    public partial class MainWindow : Window
    {
        private const string DATABASE_FILE = @"..\..\..\BD.txt";

        public MainWindow()
        {
            InitializeComponent();
        }

        private void addU(string login, string pass)
        {
            string encryptedPassword = GetSHA256Hash(pass);

            try
            {
                string userRecord = $"{login}; {encryptedPassword}";
                File.AppendAllText(DATABASE_FILE, userRecord + Environment.NewLine);
                MessageBox.Show("Пользователь успешно добавлен!", "Успех", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при добавлении пользователя: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private bool UserExists(string login)
        {
            if (!File.Exists(DATABASE_FILE))
            {
                return false;
            }

            try
            {
                string[] lines = File.ReadAllLines(DATABASE_FILE);
                foreach (string line in lines)
                {
                    if (!string.IsNullOrWhiteSpace(line))
                    {
                        string[] parts = line.Split(';');
                        if (parts.Length > 0 && parts[0].Trim() == login)
                        {
                            return true;
                        }
                    }
                }
                return false;
            }
            catch (Exception)
            {
                return false;
            }
        }

        private string GetSHA256Hash(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                // Преобразование строки в байты
                byte[] bytes = Encoding.UTF8.GetBytes(input);
                
                // Вычисление хеша
                byte[] hash = sha256.ComputeHash(bytes);
                
                // Преобразование байтов хеша в строку шестнадцатеричного формата
                StringBuilder result = new StringBuilder();
                foreach (byte b in hash)
                {
                    result.Append(b.ToString("x2"));
                }
                
                return result.ToString();
            }
        }

        private void AddUserButton_Click(object sender, RoutedEventArgs e)
        {
            string login = loginTextBox.Text;
            string password = passwordBox.Password;

            if (string.IsNullOrWhiteSpace(login) || string.IsNullOrWhiteSpace(password))
            {
                MessageBox.Show("Необходимо заполнить оба поля!", "Предупреждение", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (UserExists(login))
            {
                MessageBox.Show("Пользователь с таким логином уже существует!", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            addU(login, password);

            loginTextBox.Clear();
            passwordBox.Clear();
            loginTextBox.Focus();
        }
    }
}
