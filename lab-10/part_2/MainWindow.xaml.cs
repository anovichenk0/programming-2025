using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
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
using System.Windows.Threading;

namespace lab10._2
{
    public partial class MainWindow : Window
    {
        private DispatcherTimer timer;
        private string dbPath = "../../../BD.txt"; // Путь к файлу базы данных
        private string messagesDir = "../../Messages"; // Директория для хранения сообщений
        private string currentUser; // Текущий пользователь
        private string selectedUser; // Выбранный пользователь для чата
        private ObservableCollection<ChatMessage> messagesList; // Список сообщений в чате
        private string encryptionKey = "SuperSecretKey123"; // Ключ для шифрования сообщений

        public MainWindow()
        {
            try
            {
                InitializeComponent();
                
                // Инициализация списка сообщений и связывание с ListBox
                messagesList = new ObservableCollection<ChatMessage>();
                chatMessages.ItemsSource = messagesList;
                
                // Создаем директорию для сообщений, если она не существует
                if (!Directory.Exists(messagesDir))
                {
                    Directory.CreateDirectory(messagesDir);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка инициализации: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void txtPassword_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                btnLogin_Click(sender, e);
            }
        }

        private async void btnLogin_Click(object sender, RoutedEventArgs e)
        {
            string login = txtLogin.Text;
            string password = txtPassword.Password;

            if (string.IsNullOrWhiteSpace(login) || string.IsNullOrWhiteSpace(password))
            {
                MessageBox.Show("Введите логин и пароль", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            progressGrid.Visibility = Visibility.Visible;
            btnLogin.IsEnabled = false;

            // Шаг 1: Поиск логина в базе (1%)
            await UpdateProgressAsync(1, "поиск логина в базе");
            await Task.Delay(1000);

            bool loginExists = CheckLoginExists(login);
            if (!loginExists)
            {
                ShowError("Пользователь с таким логином не найден");
                return;
            }

            // Шаг 2: Преобразование пароля (10%)
            await UpdateProgressAsync(10, "преобразование пароля");
            await Task.Delay(1000);

            string hashedPassword = RePass(password);

            // Шаг 3: Проверка соответствия (30%)
            await UpdateProgressAsync(30, "проверка соответствия");
            await Task.Delay(1000);

            bool isValidUser = CheckCredentials(login, hashedPassword);
            if (!isValidUser)
            {
                ShowError("Неверный пароль");
                return;
            }

            // Шаг 4: Загрузка данных (68%)
            await UpdateProgressAsync(68, "загрузка данных");
            await Task.Delay(3000);

            // Успешная авторизация (100%)
            await UpdateProgressAsync(100, "авторизация успешна");
            await Task.Delay(500);

            currentUser = login;
            
            ShowWelcomeLayer(login);
        }

        private async Task UpdateProgressAsync(int value, string status)
        {
            await Dispatcher.InvokeAsync(() =>
            {
                loginProgress.Value = value;
                statusText.Text = status;
            });
        }

        private bool CheckLoginExists(string login)
        {
            if (!File.Exists(dbPath))
                return false;

            string[] lines = File.ReadAllLines(dbPath);
            return lines.Any(line => line.Split(';')[0].Trim() == login);
        }

        private bool CheckCredentials(string login, string hashedPassword)
        {
            if (!File.Exists(dbPath))
                return false;

            string[] lines = File.ReadAllLines(dbPath);
            foreach (string line in lines)
            {
                string[] parts = line.Split(';');
                if (parts.Length == 2 && parts[0].Trim() == login && parts[1].Trim() == hashedPassword)
                {
                    return true;
                }
            }
            return false;
        }

        private string RePass(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(input);
                
                byte[] hash = sha256.ComputeHash(bytes);
                
                StringBuilder result = new StringBuilder();
                foreach (byte b in hash)
                {
                    result.Append(b.ToString("x2"));
                }
                
                return result.ToString();
            }
        }

        private void ShowError(string message)
        {
            MessageBox.Show(message, "Ошибка авторизации", MessageBoxButton.OK, MessageBoxImage.Error);
            progressGrid.Visibility = Visibility.Collapsed;
            btnLogin.IsEnabled = true;
        }
        
        private void ShowWelcomeLayer(string login)
        {
            this.Title = "Няшный чатик";
            
            welcomeText.Text = "Добро пожаловать, " + login;
            
            LoadUsersList();
            
            authorizationLayer.Visibility = Visibility.Collapsed;
            welcomeLayer.Visibility = Visibility.Visible;
            
            txtLogin.Text = "";
            txtPassword.Password = "";
            progressGrid.Visibility = Visibility.Collapsed;
            btnLogin.IsEnabled = true;
        }
        
        private void logoutLink_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            this.Title = "Авторизация";
            
            welcomeLayer.Visibility = Visibility.Collapsed;
            authorizationLayer.Visibility = Visibility.Visible;
            
            messagesList.Clear();
            selectedUser = null;
            currentUser = null;
            txtMessage.IsEnabled = false;
            btnSendMessage.IsEnabled = false;
            chatHeader.Text = "Выберите пользователя для начала чата";
        }
        
        private void ScrollViewer_PreviewMouseWheel(object sender, MouseWheelEventArgs e)
        {
            ScrollViewer scrollViewer = sender as ScrollViewer;
            if (scrollViewer != null)
            {
                double scrollSpeed = 48.0;
                
                if (e.Delta > 0)
                    scrollViewer.ScrollToVerticalOffset(scrollViewer.VerticalOffset - scrollSpeed);
                else
                    scrollViewer.ScrollToVerticalOffset(scrollViewer.VerticalOffset + scrollSpeed);
                
                e.Handled = true;
            }
        }
        
        private void LoadUsersList()
        {
            try
            {
                if (File.Exists(dbPath))
                {
                    usersList.Items.Clear();
                    
                    string[] lines = File.ReadAllLines(dbPath);
                    foreach (string line in lines)
                    {
                        string[] parts = line.Split(';');
                        if (parts.Length >= 1)
                        {
                            string username = parts[0].Trim();
                            
                            if (username != currentUser)
                            {
                                usersList.Items.Add(username);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка загрузки списка пользователей: {ex.Message}", 
                               "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        private void usersList_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (usersList.SelectedItem != null)
            {
                selectedUser = usersList.SelectedItem.ToString();
                chatHeader.Text = $"Чат с пользователем: {selectedUser}";
                
                txtMessage.IsEnabled = true;
                btnSendMessage.IsEnabled = true;
                
                LoadChatHistory();
                
                txtMessage.Focus();
            }
        }
        
        private void btnSendMessage_Click(object sender, RoutedEventArgs e)
        {
            SendMessageIfNotEmpty();
        }
        
        private void txtMessage_PreviewKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter && !Keyboard.IsKeyDown(Key.LeftShift) && !Keyboard.IsKeyDown(Key.RightShift))
            {
                e.Handled = true;
                SendMessageIfNotEmpty();
            }
        }
        
        private void SendMessageIfNotEmpty()
        {
            if (string.IsNullOrWhiteSpace(txtMessage.Text))
                return;
                
            if (selectedUser != null)
            {
                string messageText = txtMessage.Text.Trim();
                SendMessage(messageText);
                txtMessage.Clear();
            }
        }
        
        private void SendMessage(string messageText)
        {
            try
            {
                string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                
                string encryptedMessage = EncryptString(messageText);
                
                string chatFile = GetChatFilePath(currentUser, selectedUser);
                string messageEntry = $"{currentUser};{timestamp};{encryptedMessage}";
                
                File.AppendAllLines(chatFile, new[] { messageEntry });
                
                ChatMessage message = new ChatMessage 
                { 
                    Sender = currentUser, 
                    Content = messageText, 
                    Timestamp = timestamp,
                    IsOwnMessage = true
                };
                
                messagesList.Add(message);
                
                chatMessages.ScrollIntoView(chatMessages.Items[chatMessages.Items.Count - 1]);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка отправки сообщения: {ex.Message}", 
                               "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        private string GetChatFilePath(string user1, string user2)
        {
            string[] users = new[] { user1, user2 };
            Array.Sort(users);
            
            return System.IO.Path.Combine(messagesDir, $"{users[0]}_{users[1]}.txt");
        }
        
        private void LoadChatHistory()
        {
            try
            {
                messagesList.Clear();
                string chatFile = GetChatFilePath(currentUser, selectedUser);
                
                if (File.Exists(chatFile))
                {
                    string[] lines = File.ReadAllLines(chatFile);
                    foreach (string line in lines)
                    {
                        string[] parts = line.Split(';');
                        if (parts.Length >= 3)
                        {
                            string sender = parts[0].Trim();
                            string timestamp = parts[1].Trim();
                            string encryptedMessage = parts[2].Trim();
                            
                            string decryptedMessage = DecryptString(encryptedMessage);
                            
                            ChatMessage message = new ChatMessage
                            {
                                Sender = sender,
                                Content = decryptedMessage,
                                Timestamp = timestamp,
                                IsOwnMessage = (sender == currentUser)
                            };
                            
                            messagesList.Add(message);
                        }
                    }
                    
                    if (chatMessages.Items.Count > 0)
                    {
                        chatMessages.ScrollIntoView(chatMessages.Items[chatMessages.Items.Count - 1]);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка загрузки истории чата: {ex.Message}", 
                               "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        private string EncryptString(string plainText)
        {
            byte[] iv = new byte[16];
            byte[] array;

            using (Aes aes = Aes.Create())
            {
                aes.Key = Encoding.UTF8.GetBytes(encryptionKey.PadRight(32).Substring(0, 32));
                aes.IV = iv;

                ICryptoTransform encryptor = aes.CreateEncryptor(aes.Key, aes.IV);

                using (MemoryStream memoryStream = new MemoryStream())
                {
                    using (CryptoStream cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write))
                    {
                        using (StreamWriter streamWriter = new StreamWriter(cryptoStream))
                        {
                            streamWriter.Write(plainText);
                        }

                        array = memoryStream.ToArray();
                    }
                }
            }

            return Convert.ToBase64String(array);
        }

        private string DecryptString(string cipherText)
        {
            byte[] iv = new byte[16];
            byte[] buffer = Convert.FromBase64String(cipherText);

            using (Aes aes = Aes.Create())
            {
                aes.Key = Encoding.UTF8.GetBytes(encryptionKey.PadRight(32).Substring(0, 32));
                aes.IV = iv;
                ICryptoTransform decryptor = aes.CreateDecryptor(aes.Key, aes.IV);

                using (MemoryStream memoryStream = new MemoryStream(buffer))
                {
                    using (CryptoStream cryptoStream = new CryptoStream(memoryStream, decryptor, CryptoStreamMode.Read))
                    {
                        using (StreamReader streamReader = new StreamReader(cryptoStream))
                        {
                            return streamReader.ReadToEnd();
                        }
                    }
                }
            }
        }
    }
    
    public class ChatMessage
    {
        public string Sender { get; set; }
        public string Content { get; set; }
        public string Timestamp { get; set; }
        public bool IsOwnMessage { get; set; }
        
        public HorizontalAlignment Alignment => IsOwnMessage ? HorizontalAlignment.Right : HorizontalAlignment.Left;
        
        public string MessageColor => IsOwnMessage ? "#E3F5FC" : "#FFFFFF";
    }
}
