std = "luajit"
globals = { "love" }
max_line_length = false
-- проверяем только синтаксис и неопределённые переменные
ignore = { "2..", "3..", "4..", "5..", "6.." }
files["test"] = { std = "+busted" }
