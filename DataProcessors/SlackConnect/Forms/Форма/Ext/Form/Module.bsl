﻿
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Элементы.Method.СписокВыбора.Добавить("chat.postMessage");
	Элементы.Method.СписокВыбора.Добавить("chat.meMessage");
	Элементы.Method.СписокВыбора.Добавить("chat.update");
	Элементы.Method.СписокВыбора.Добавить("emoji.list");
	Элементы.Method.СписокВыбора.Добавить("bots.info");	
	Элементы.Method.СписокВыбора.Добавить("users.conversations");
	Элементы.Method.СписокВыбора.Добавить("chat.postMessage");

	
	АдресСервера = "slack.com";	
	api = "api/Method?token=";
	text = "тестовое сообщение";
	
КонецПроцедуры

&НаКлиенте
Процедура Отправить(Команда)
	ОтправитьСообщение();
КонецПроцедуры

&НаСервере
Процедура ОтправитьСообщение()
	
	Структура = Новый Структура;
	Для каждого стр из ТаблицаПараметров Цикл
		Структура.Вставить(стр.Параметр,стр.Значение);		
	КонецЦикла;	
	
	Ошибка = Ложь;
	Сообщение = "";
	SlackURL = api + bot.Token;
    Тело = "";
   	Для Каждого Зн Из Структура Цикл
		Если Зн.Значение <> "" тогда
			Тело = Тело + "&" + Зн.Ключ + "=" + КодироватьСтроку(Зн.Значение, СпособКодированияСтроки.КодировкаURL, КодировкаТекста.UTF8);
		КонецЕсли;
	КонецЦикла;
  	Сообщение = Сообщение + "Тело: " + Тело + Символы.ПС;
	HTTPЗапрос = Новый HTTPЗапрос;                                                               
    HTTPЗапрос.АдресРесурса = SlackURL;
    HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded;");
    HTTPЗапрос.УстановитьТелоИзСтроки(Тело, "Windows-1251");

    Соединение = Новый HTTPСоединение(АдресСервера,,,,, 10, Новый ЗащищенноеСоединениеOpenSSL);
	
	Попытка 
		ОтветHTTP = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
    Исключение
        Попытка
			ОтветHTTP = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
        Исключение			
			Сообщение = Сообщение + "Сообщение не отправлено. Код ошибки: " + Символы.ПС + ОписаниеОшибки() + Символы.ПС;
            Ошибка = Истина;
        КонецПопытки;
    КонецПопытки;
	
	Если НЕ Ошибка Тогда
		
		Поток = ОтветHTTP.ПолучитьТелоКакПоток();
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.ОткрытьПоток(Поток);
		Попытка
			Данные = ПрочитатьJSON(ЧтениеJSON,ложь);
			Сообщить(Данные);
			Сообщение = Сообщение + "Ответ сервера:" + Символы.ПС;
			Для Каждого Элемент Из Данные Цикл
				Сообщение = Сообщение + Элемент.Ключ + " " + Элемент.Значение + Символы.ПС;
			КонецЦикла;
		исключение
			
		КонецПопытки;
		Ответ = ОтветHTTP.ПолучитьТелоКакСтроку();
		Если Ответ = "ok" Тогда
			Сообщение = Сообщение + "Сообщение отправлено";
		Иначе
			Сообщение = Сообщение + "Код ответа сервера: " + Ответ + Символы.ПС + ОписаниеОшибки();			
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура MethodОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ТаблицаПараметров.Очистить();
	api = "api/" + ВыбранноеЗначение + "?token=";
	Если ВыбранноеЗначение = "chat.postMessage" Тогда 		
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "channel";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "text";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "as_user";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "attachments";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "blocks";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "icon_emoji";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "icon_url";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "link_names";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "mrkdwn";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "parse";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "reply_broadcast";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "thread_ts";
		стр.Значение = "";                   
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "unfurl_links";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "unfurl_media";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "username";
		стр.Значение = "";
	ИначеЕсли ВыбранноеЗначение = "emoji.list" Тогда
	ИначеЕсли ВыбранноеЗначение = "bots.info" Тогда	
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "bot";
		стр.Значение = "";
	ИначеЕсли ВыбранноеЗначение = "chat.meMessage" Тогда 
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "channel";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "text";
		стр.Значение = "";
	ИначеЕсли ВыбранноеЗначение = "chat.update" Тогда
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "channel";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "ts";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "as_user";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "attachments";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "blocks";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "link_names";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "parse";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "text";
		стр.Значение = "";        
	ИначеЕсли ВыбранноеЗначение = "users.conversations" Тогда
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "cursor";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "exclude_archived";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "limit";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "types";
		стр.Значение = "";
		стр = ТаблицаПараметров.Добавить();
		стр.Параметр =  "user";
		стр.Значение = "";
	КонецЕсли;
	
КонецПроцедуры

 &НаКлиенте
Процедура ДобавитьВОчередьОтправки(Команда)
	ДобавитьВОчередьОтправкиНаСервере();
КонецПроцедуры

&НаСервере
Процедура ДобавитьВОчередьОтправкиНаСервере()
	
	Запись = РегистрыСведений.Slack_ИсторияСообщений.СоздатьМенеджерЗаписи();
	Запись.Период = ТекущаяДата();
	Запись.Bot = Bot;
	Запись.UserID = channel;
	Запись.Сообщение = text;
	Запись.Записать(Истина);
	
КонецПроцедуры

