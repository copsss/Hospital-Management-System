
# Hospital Management System

## 项目简介
这是一个基于Python的医院管理系统项目，旨在简化医院的各种管理任务。该系统使用MySQL作为数据库，并通过PyQt5提供用户界面。通过`main.py`文件启动程序。

## 功能特性
- 患者管理
- 医生管理
- 预约管理
- 财务管理
- 药品管理

## 安装说明

### 先决条件
在开始之前，请确保你已经安装了以下软件：
- Python 3.x
- MySQL

### 克隆仓库
首先，克隆此仓库到你的本地机器：
```sh
git clone https://github.com/copsss/Hospital-Management-System.git
cd Hospital-Management-System
```

### 创建并配置数据库
1. 登录到你的MySQL数据库：
    ```sh
    mysql -u your-username -p
    ```
2. 创建数据库`hms`：
    ```sql
    CREATE DATABASE hms;
    ```
3. 导入项目中的SQL脚本以初始化数据库结构：
    ```sh
    mysql -u your-username -p hms < database/hms.sql
    ```

### 安装依赖项
使用pip安装项目所需的Python依赖项：
```sh
pip install -r requirements.txt
```

## 运行程序
进入项目目录并运行`main.py`文件启动程序：
```sh
python main.py
```

## 文件结构
```
Hospital-Management-System/
├── database/
│   └── hms.sql           # 数据库初始化脚本
├── src/
│   ├── main.py           # 程序入口文件
│   ├── ...               # 其他源代码文件
├── README.md             # 项目说明文件
├── requirements.txt      # Python依赖项列表
└── ...
```

## 贡献
欢迎对本项目进行贡献！如果你有任何建议或发现任何问题，请提交issue或创建pull request。



## 联系方式
如果你有任何问题，请通过以下方式联系我们：
- Email: zumingshen001@gmail.com

感谢你对本项目的支持！
