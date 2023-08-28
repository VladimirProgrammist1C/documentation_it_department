﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастройкаПроксиНаКлиенте = Параметры.НастройкаПроксиНаКлиенте;
	Если НЕ Параметры.НастройкаПроксиНаКлиенте
		И НЕ Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав доступа.
			|
			|Настройка прокси-сервера выполняется администратором.';
			|en = 'Insufficient access rights.
			|
			|Only administrators can configure proxy servers.'");
	КонецЕсли;
	
	Если НастройкаПроксиНаКлиенте Тогда
		НастройкаПроксиСервера = ПолучениеФайловИзИнтернета.НастройкиПроксиНаКлиенте();
	Иначе
		АвтоЗаголовок = Ложь;
		Заголовок = НСтр("ru = 'Параметры прокси-сервера на сервере 1С:Предприятия';
						|en = 'Proxy server parameters on 1C:Enterprise server'");
		НастройкаПроксиСервера = ПолучениеФайловИзИнтернета.НастройкиПроксиНаСервере();
	КонецЕсли;
	
	ИспользоватьПрокси = Истина;
	ИспользоватьСистемныеНастройки = Истина;
	Если ТипЗнч(НастройкаПроксиСервера) = Тип("Соответствие") Тогда
		
		ИспользоватьПрокси = НастройкаПроксиСервера.Получить("ИспользоватьПрокси");
		ИспользоватьСистемныеНастройки = НастройкаПроксиСервера.Получить("ИспользоватьСистемныеНастройки");
		
		Если ИспользоватьПрокси И НЕ ИспользоватьСистемныеНастройки Тогда
			
			// Заполнить данные формы настройками, заданными вручную.
			Сервер       = НастройкаПроксиСервера.Получить("Сервер");
			Пользователь = НастройкаПроксиСервера.Получить("Пользователь");
			Пароль       = НастройкаПроксиСервера.Получить("Пароль");
			Порт         = НастройкаПроксиСервера.Получить("Порт");
			НеИспользоватьПроксиДляЛокальныхАдресов = НастройкаПроксиСервера.Получить("НеИспользоватьПроксиДляЛокальныхАдресов");
			ЗначениеПараметра = НастройкаПроксиСервера.Получить("ИспользоватьАутентификациюОС");
			ИспользоватьАутентификациюОС = ?(ЗначениеПараметра = Неопределено, 0, Число(ЗначениеПараметра));
			
			АдресаСерверовИсключенийМассив = НастройкаПроксиСервера.Получить("НеИспользоватьПроксиДляАдресов");
			Если ТипЗнч(АдресаСерверовИсключенийМассив) = Тип("Массив") Тогда
				СерверыИсключений.ЗагрузитьЗначения(АдресаСерверовИсключенийМассив);
			КонецЕсли;
			
			ДополнительныеПрокси = НастройкаПроксиСервера.Получить("ДополнительныеНастройкиПрокси");
			
			Если ТипЗнч(ДополнительныеПрокси) <> Тип("Соответствие") Тогда
				ОдинПроксиДляВсехПротоколов = Истина;
			Иначе
				
				// Если в настройках заданы дополнительные прокси-серверы,
				// то прочитать их из настроек.
				Для каждого ПротоколСервер Из ДополнительныеПрокси Цикл
					Протокол             = ПротоколСервер.Ключ;
					НастройкаПоПротоколу = ПротоколСервер.Значение;
					ЭтотОбъект["Сервер" + Протокол] = НастройкаПоПротоколу.Адрес;
					ЭтотОбъект["Порт"   + Протокол] = НастройкаПоПротоколу.Порт;
				КонецЦикла;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Варианты использования прокси-сервера:
	// 0 - Не использовать прокси-сервер (по умолчанию, соответствует Новый ИнтернетПрокси(Ложь)).
	// 1 - Использовать системные настройки прокси-сервера (соответствует Новый ИнтернетПрокси(Истина)).
	// 2 - Использовать свои настройки прокси-сервера (соответствует ручной настройке параметров прокси-сервера).
	// Для последнего становятся доступно ручное изменение параметров прокси-сервера.
	ВариантИспользованияПроксиСервера = ?(ИспользоватьПрокси, ?(ИспользоватьСистемныеНастройки = Истина, 1, 2), 0);
	Если ВариантИспользованияПроксиСервера = 0 Тогда
		ИнициализироватьЭлементыФормы(ЭтотОбъект, ПустыеНастройкиПроксиСервера());
	ИначеЕсли ВариантИспользованияПроксиСервера = 1 И Не НастройкаПроксиНаКлиенте Тогда
		ИнициализироватьЭлементыФормы(ЭтотОбъект, СистемныеНастройкиПроксиСервера());
	КонецЕсли;
	
	УстановитьВидимостьДоступность(ЭтотОбъект);
	
	Если Не ПравоДоступа("СохранениеДанныхПользователя", Метаданные) Тогда
		ТолькоПросмотр = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если НастройкаПроксиНаКлиенте Тогда
#Если ВебКлиент Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'В веб-клиенте параметры прокси-сервера необходимо задавать в настройках браузера.';
										|en = 'Please specify the proxy server parameters in the browser settings.'"));
		Отказ = Истина;
		Возврат;
#КонецЕсли
		
		Если ВариантИспользованияПроксиСервера = 1 Тогда
			ИнициализироватьЭлементыФормы(ЭтотОбъект, СистемныеНастройкиПроксиСервера());
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ВРег(ИсточникВыбора.ИмяФормы) = ВРег("ОбщаяФорма.ДополнительныеПараметрыПроксиСервера") Тогда
		
		Если ТипЗнч(ВыбранноеЗначение) <> Тип("Структура") Тогда
			Возврат;
		КонецЕсли;
		
		Для Каждого КлючИЗначение Из ВыбранноеЗначение Цикл
			Если КлючИЗначение.Ключ <> "НеИспользоватьПроксиДляАдресов" Тогда
				ЭтотОбъект[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
			КонецЕсли;
		КонецЦикла;
		
		СерверыИсключений = ВыбранноеЗначение.НеИспользоватьПроксиДляАдресов;
		
		Модифицированность = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Оповещение = Новый ОписаниеОповещения("ВыбратьИЗакрыть", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияФормы(Оповещение, Отказ, ЗавершениеРаботы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ВариантыИспользованияПроксиСервераПриИзменении(Элемент)
	
	ИспользоватьПрокси = (ВариантИспользованияПроксиСервера > 0);
	ИспользоватьСистемныеНастройки = (ВариантИспользованияПроксиСервера = 1);
	
	НастройкиПрокси = Неопределено;
	// Варианты настройки прокси-сервера:
	// 0 - Не использовать прокси-сервер (по умолчанию, соответствует Новый ИнтернетПрокси(Ложь)).
	// 1 - Использовать системные настройки прокси-сервера (соответствует Новый ИнтернетПрокси(Истина)).
	// 2 - Использовать свои настройки прокси-сервера (соответствует ручной настройке параметров прокси-сервера).
	// Для последнего становятся доступно ручное изменение параметров прокси-сервера.
	Если ВариантИспользованияПроксиСервера = 0 Тогда
		НастройкиПрокси = ПустыеНастройкиПроксиСервера();
	ИначеЕсли ВариантИспользованияПроксиСервера = 1 Тогда
		НастройкиПрокси = ?(НастройкаПроксиНаКлиенте,
							СистемныеНастройкиПроксиСервера(),
							СистемныеНастройкиПроксиСервераНаСервере());
	КонецЕсли;
	
	ИнициализироватьЭлементыФормы(ЭтотОбъект, НастройкиПрокси);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ДополнительныеПараметрыПроксиСервера(Команда)
	
	// Формирование параметров для дополнительных настроек.
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ТолькоПросмотр", Не ДоступноРедактирование);
	
	ПараметрыФормы.Вставить("ОдинПроксиДляВсехПротоколов", ОдинПроксиДляВсехПротоколов);
	
	ПараметрыФормы.Вставить("Сервер"     , Сервер);
	ПараметрыФормы.Вставить("Порт"       , Порт);
	ПараметрыФормы.Вставить("СерверHTTP" , СерверHTTP);
	ПараметрыФормы.Вставить("ПортHTTP"   , ПортHTTP);
	ПараметрыФормы.Вставить("СерверHTTPS", СерверHTTPS);
	ПараметрыФормы.Вставить("ПортHTTPS"  , ПортHTTPS);
	ПараметрыФормы.Вставить("СерверFTP"  , СерверFTP);
	ПараметрыФормы.Вставить("ПортFTP"    , ПортFTP);
	
	ПараметрыФормы.Вставить("НеИспользоватьПроксиДляАдресов", СерверыИсключений);
	
	ОткрытьФорму("ОбщаяФорма.ДополнительныеПараметрыПроксиСервера", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура КнопкаОК(Команда)
	
	// Сохраняет настройки прокси-сервера и закрывает форму,
	// передавая в качестве возвращаемого результата параметры прокси.
	СохранитьНастройкиПроксиСервера();
	
КонецПроцедуры

&НаКлиенте
Процедура КнопкаОтмена(Команда)
	
	Модифицированность = Ложь;
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ИнициализироватьЭлементыФормы(Форма, НастройкиПрокси)
	
	Если НастройкиПрокси <> Неопределено Тогда
		
		Форма.Сервер       = НастройкиПрокси.Сервер;
		Форма.Порт         = НастройкиПрокси.Порт;
		Форма.СерверHTTP   = НастройкиПрокси.СерверHTTP;
		Форма.ПортHTTP     = НастройкиПрокси.ПортHTTP;
		Форма.СерверHTTPS  = НастройкиПрокси.СерверHTTPS;
		Форма.ПортHTTPS    = НастройкиПрокси.ПортHTTPS;
		Форма.СерверFTP    = НастройкиПрокси.СерверFTP;
		Форма.ПортFTP      = НастройкиПрокси.ПортFTP;
		Форма.Пользователь = НастройкиПрокси.Пользователь;
		Форма.Пароль       = НастройкиПрокси.Пароль;
		Форма.НеИспользоватьПроксиДляЛокальныхАдресов = НастройкиПрокси.НеИспользоватьПроксиДляЛокальныхАдресов;
		Форма.СерверыИсключений.ЗагрузитьЗначения(НастройкиПрокси.НеИспользоватьПроксиДляАдресов);
		Форма.ИспользоватьАутентификациюОС = ?(НастройкиПрокси.ИспользоватьАутентификациюОС, 1, 0);
		
		// Если настройки по всем протоколам совпадают с настройками прокси
		// по умолчанию, то считаем, что один прокси используется для всех протоколов.
		Форма.ОдинПроксиДляВсехПротоколов = (Форма.Сервер = Форма.СерверHTTP
			И Форма.СерверHTTP = Форма.СерверHTTPS
			И Форма.СерверHTTPS = Форма.СерверFTP
			И Форма.Порт = Форма.ПортHTTP
			И Форма.ПортHTTP = Форма.ПортHTTPS
			И Форма.ПортHTTPS = Форма.ПортFTP);
		
	КонецЕсли;
	
	УстановитьВидимостьДоступность(Форма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимостьДоступность(Форма)
	
	// Изменяем доступность группы редактирования параметров прокси в зависимости
	// от варианта использования прокси-сервера.
	Форма.ДоступноРедактирование = (Форма.ВариантИспользованияПроксиСервера = 2);
	
	Форма.Элементы.ГруппаАдресСервера.Доступность = Форма.ДоступноРедактирование;
	Форма.Элементы.ГруппаАутентификация.Доступность = Форма.ДоступноРедактирование;
	Форма.Элементы.НеИспользоватьПроксиДляЛокальныхАдресов.Доступность = Форма.ДоступноРедактирование;
	
КонецПроцедуры

// Выполняет сохранение настроек прокси-сервера в интерактивном режиме в
// результате действий пользователя с отображением сообщений пользователю,
// после чего закрывает форму с возвратом настроек прокси-сервера.
//
&НаКлиенте
Процедура СохранитьНастройкиПроксиСервера(ЗакрытьФорму = Истина)
	
	НастройкаПроксиСервера = Новый Соответствие;
	
	НастройкаПроксиСервера.Вставить("ИспользоватьПрокси", ИспользоватьПрокси);
	НастройкаПроксиСервера.Вставить("Пользователь"      , Пользователь);
	НастройкаПроксиСервера.Вставить("Пароль"            , Пароль);
	НастройкаПроксиСервера.Вставить("Сервер"            , НормализованныйАдресПроксиСервера(Сервер));
	НастройкаПроксиСервера.Вставить("Порт"              , Порт);
	НастройкаПроксиСервера.Вставить("НеИспользоватьПроксиДляЛокальныхАдресов", НеИспользоватьПроксиДляЛокальныхАдресов);
	НастройкаПроксиСервера.Вставить("НеИспользоватьПроксиДляАдресов", СерверыИсключений.ВыгрузитьЗначения());
	НастройкаПроксиСервера.Вставить("ИспользоватьСистемныеНастройки", ИспользоватьСистемныеНастройки);
	НастройкаПроксиСервера.Вставить("ИспользоватьАутентификациюОС", Булево(ИспользоватьАутентификациюОС));
	
	
	// Формирование дополнительных адресов прокси-серверов.
	
	Если НЕ ОдинПроксиДляВсехПротоколов Тогда
		
		ДополнительныеНастройки = Новый Соответствие;
		Если НЕ ПустаяСтрока(СерверHTTP) Тогда
			ДополнительныеНастройки.Вставить("http",
				Новый Структура("Адрес,Порт", НормализованныйАдресПроксиСервера(СерверHTTP), ПортHTTP));
		КонецЕсли;
		
		Если НЕ ПустаяСтрока(СерверHTTPS) Тогда
			ДополнительныеНастройки.Вставить("https",
				Новый Структура("Адрес,Порт", НормализованныйАдресПроксиСервера(СерверHTTPS), ПортHTTPS));
		КонецЕсли;
		
		Если НЕ ПустаяСтрока(СерверFTP) Тогда
			ДополнительныеНастройки.Вставить("ftp",
				Новый Структура("Адрес,Порт", НормализованныйАдресПроксиСервера(СерверFTP), ПортFTP));
		КонецЕсли;
		
		Если ДополнительныеНастройки.Количество() > 0 Тогда
			НастройкаПроксиСервера.Вставить("ДополнительныеНастройкиПрокси", ДополнительныеНастройки);
		КонецЕсли;
		
	КонецЕсли;
	
	ЗаписатьНастройкиПроксиСервераВИнформационнуюБазу(НастройкаПроксиНаКлиенте, НастройкаПроксиСервера);
	
	Модифицированность = Ложь;
	
	Если ЗакрытьФорму Тогда
		
		Закрыть(НастройкаПроксиСервера);
		
	КонецЕсли;
	
КонецПроцедуры

// Выполняет непосредственное сохранение настроек прокси-сервера.
&НаСервереБезКонтекста
Процедура ЗаписатьНастройкиПроксиСервераВИнформационнуюБазу(НастройкаПроксиНаКлиенте, НастройкаПроксиСервера)
	
	Если НастройкаПроксиНаКлиенте
	 Или ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("НастройкаПроксиСервера", "", НастройкаПроксиСервера);
	Иначе
		ПолучениеФайловИзИнтернетаСлужебный.СохранитьНастройкиПроксиНаСервере1СПредприятие(НастройкаПроксиСервера);
	КонецЕсли;
	ОбновитьПовторноИспользуемыеЗначения();
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПустыеНастройкиПроксиСервера()
	
	Результат = Новый Структура;
	Результат.Вставить("Сервер"      , "");
	Результат.Вставить("Порт"        , 0);
	Результат.Вставить("СерверHTTP"  , "");
	Результат.Вставить("ПортHTTP"    , 0);
	Результат.Вставить("СерверHTTPS" , "");
	Результат.Вставить("ПортHTTPS"   , 0);
	Результат.Вставить("СерверFTP"   , "");
	Результат.Вставить("ПортFTP"     , 0);
	Результат.Вставить("Пользователь", "");
	Результат.Вставить("Пароль"      , "");
	
	Результат.Вставить("ИспользоватьАутентификациюОС", Ложь);
	
	Результат.Вставить("НеИспользоватьПроксиДляЛокальныхАдресов", Ложь);
	Результат.Вставить("НеИспользоватьПроксиДляАдресов", Новый Массив);
	
	Возврат Результат;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция СистемныеНастройкиПроксиСервера()

#Если ВебКлиент Тогда

	Возврат ПустыеНастройкиПроксиСервера();
	
#Иначе	
	
	Прокси = Новый ИнтернетПрокси(Истина);
	
	Результат = Новый Структура;
	Результат.Вставить("Сервер", Прокси.Сервер());
	Результат.Вставить("Порт"  , Прокси.Порт());
	
	Результат.Вставить("СерверHTTP" , Прокси.Сервер("http"));
	Результат.Вставить("ПортHTTP"   , Прокси.Порт("http"));
	Результат.Вставить("СерверHTTPS", Прокси.Сервер("https"));
	Результат.Вставить("ПортHTTPS"  , Прокси.Порт("https"));
	Результат.Вставить("СерверFTP"  , Прокси.Сервер("ftp"));
	Результат.Вставить("ПортFTP"    , Прокси.Порт("ftp"));
	
	Результат.Вставить("Пользователь", Прокси.Пользователь(""));
	Результат.Вставить("Пароль"      , Прокси.Пароль(""));
	Результат.Вставить("ИспользоватьАутентификациюОС", Прокси.ИспользоватьАутентификациюОС(""));
	
	Результат.Вставить("НеИспользоватьПроксиДляЛокальныхАдресов",
		Прокси.НеИспользоватьПроксиДляЛокальныхАдресов);
	
	НеИспользоватьПроксиДляАдресов = Новый Массив;
	Для Каждого АдресСервера Из Прокси.НеИспользоватьПроксиДляАдресов Цикл
		НеИспользоватьПроксиДляАдресов.Добавить(АдресСервера);
	КонецЦикла;
	Результат.Вставить("НеИспользоватьПроксиДляАдресов", НеИспользоватьПроксиДляАдресов);
	
	Возврат Результат;
	
#КонецЕсли
	
КонецФункции

&НаСервереБезКонтекста
Функция СистемныеНастройкиПроксиСервераНаСервере()
	
	Возврат СистемныеНастройкиПроксиСервера();
	
КонецФункции

// Возвращает нормализованный адрес прокси-сервера - без пробелов.
// Если между значащими символами встречаются пробелы, то адрес
// обрезается до первого пробела.
//
// Параметры:
//  АдресПроксиСервера - Строка - нормализуемый адрес прокси-сервера.
//
// Возвращаемое значение:
//   Строка - нормализованный адрес прокси-сервера.
//
&НаКлиентеНаСервереБезКонтекста
Функция НормализованныйАдресПроксиСервера(Знач АдресПроксиСервера)
	
	АдресПроксиСервера = СокрЛП(АдресПроксиСервера);
	ПозицияПробела = СтрНайти(АдресПроксиСервера, " ");
	Если ПозицияПробела > 0 Тогда
		// Если в адресе сервера присутствуют пробелы, то
		// берется часть адреса перед первым пробелом.
		АдресПроксиСервера = Лев(АдресПроксиСервера, ПозицияПробела - 1);
	КонецЕсли;
	
	Возврат АдресПроксиСервера;
	
КонецФункции

&НаКлиенте
Процедура ВыбратьИЗакрыть(Результат = Неопределено, ДополнительныеПараметры = Неопределено) Экспорт
	
	СохранитьНастройкиПроксиСервера();
	
КонецПроцедуры

#КонецОбласти
