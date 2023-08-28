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
	
	ЭтоНоваяГруппа = Параметры.ЭтоНоваяГруппа;
	
	Если ЭтоНоваяГруппа Тогда
		
		ОбъектЗначение = Справочники[Параметры.ИмяСправочникаХранилищаФайлов].СоздатьГруппу();
		Если Параметры.Свойство("Родитель")
			И Параметры.Родитель <> Неопределено
			И ТипЗнч(Параметры.Родитель) = ТипЗнч(ОбъектЗначение.Ссылка) Тогда
			
			Если Параметры.Родитель.ЭтоГруппа Тогда
				ОбъектЗначение.Родитель = Параметры.Родитель;
			ИначеЕсли Параметры.Родитель.Родитель <> Неопределено
				И ТипЗнч(Параметры.Родитель.Родитель) = ТипЗнч(ОбъектЗначение.Ссылка) Тогда
				
				ОбъектЗначение.Родитель = Параметры.Родитель.Родитель; // В качестве первого родителя была передана ссылка на элемент.
			КонецЕсли;
			
		Иначе
			ОбъектЗначение.Родитель = Неопределено;
		КонецЕсли;
		
		ОбъектЗначение.ВладелецФайла = Параметры.ВладелецФайла;
		ОбъектЗначение.ДатаСоздания  = ТекущаяУниверсальнаяДата();
		ОбъектЗначение.Автор         = Пользователи.АвторизованныйПользователь();
		ОбъектЗначение.Изменил       = ОбъектЗначение.Автор;
		
	ИначеЕсли ЗначениеЗаполнено(Параметры.ЗначениеКопирования) Тогда
		
		КопируемыйОбъект        = Параметры.ЗначениеКопирования.ПолучитьОбъект();
		ОбъектЗначение          = Справочники[КопируемыйОбъект.Метаданные().Имя].СоздатьГруппу();
		ОбъектЗначение.Родитель = Параметры.Родитель;
		
		ЗаполнитьЗначенияСвойств(ОбъектЗначение, КопируемыйОбъект,
			"ВладелецФайла, ДатаСоздания, Описание, Наименование, ДатаМодификацииУниверсальная, Изменил");
		
		ОбъектЗначение.Автор = Пользователи.АвторизованныйПользователь();
		
	Иначе
		
		Если ЗначениеЗаполнено(Параметры.ПрисоединенныйФайл) Тогда
			ОбъектЗначение = Параметры.ПрисоединенныйФайл.ПолучитьОбъект();
		ИначеЕсли ЗначениеЗаполнено(Параметры.Ключ) Тогда
			ОбъектЗначение = Параметры.Ключ.ПолучитьОбъект();
		Иначе
			ВызватьИсключение НСтр("ru = 'Не предусмотрено непосредственное создание группы файлов.';
									|en = 'You cannot create a file group.'");
		КонецЕсли;
		
	КонецЕсли;
	ОбъектЗначение.Заполнить(Неопределено);
	
	ИмяСправочника = ОбъектЗначение.Метаданные().Имя;
	
	НастроитьОбъектФормы(ОбъектЗначение);
	
	Если ТолькоПросмотр
		Или Не ПравоДоступа("Изменение", ЭтотОбъект.Объект.ВладелецФайла.Метаданные()) Тогда
		
		Элементы.ФормаСтандартнаяЗаписать.Доступность                  = Ложь;
		Элементы.ФормаСтандартнаяЗаписатьИЗакрыть.Доступность          = Ложь;
		Элементы.ФормаСтандартнаяУстановитьПометкуУдаления.Доступность = Ложь;
		
	КонецЕсли;
	
	Если Не ТолькоПросмотр
		И Не ТекущаяСсылкаНаФайлСервер().Пустая() Тогда
		
		ЗаблокироватьДанныеДляРедактирования(ТекущаяСсылкаНаФайлСервер(), , УникальныйИдентификатор);
	КонецЕсли;
	
	ОбновитьЗаголовок();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если Модифицированность Тогда
		
		Отказ = Истина;
		ОповещениеОбОтвете = Новый ОписаниеОповещения("ЗакрытьФормуПослеОтветаНаВопрос", ЭтотОбъект);
		ПоказатьВопрос(ОповещениеОбОтвете, НСтр("ru = 'Данные были изменены. Сохранить изменения?';
												|en = 'The data has been changed. Do you want to save the changes?'"), РежимДиалогаВопрос.ДаНетОтмена);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СтандартнаяЗаписать(Команда)
	ОбработатьКомандуЗаписиФайла();
КонецПроцедуры

&НаКлиенте
Процедура СтандартнаяЗаписатьИЗакрыть(Команда)
	
	Если ОбработатьКомандуЗаписиФайла() Тогда
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СтандартнаяПеречитать(Команда)
	
	Если ЭтоНовый() Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ Модифицированность Тогда
		ПеречитатьДанныеССервера();
		Возврат;
	КонецЕсли;
	
	ТекстВопроса = НСтр("ru = 'Данные изменены. Перечитать данные?';
						|en = 'The data has been changed. Do you want to refresh the data?'");
	
	ОписаниеОповещения = Новый ОписаниеОповещения("СтандартнаяПеречитатьОтветПолучен", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да);
	
КонецПроцедуры

&НаКлиенте
Процедура СтандартнаяСкопировать(Команда)
	
	Если ЭтоНовый() Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура("ЗначениеКопирования", ТекущаяСсылкаНаФайл());
	ОткрытьФорму("Обработка.РаботаСФайлами.Форма.ГруппаФайлов", ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура СтандартнаяПоказатьВСписке(Команда)
	
	СтандартныеПодсистемыКлиент.ПоказатьВСписке(ТекущаяСсылкаНаФайл(), Неопределено);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура НастроитьОбъектФормы(Знач НовыйОбъект)
	
	ТипНовогоОбъекта = Новый Массив;
	ТипНовогоОбъекта.Добавить(ТипЗнч(НовыйОбъект));
	
	НовыйРеквизит = Новый РеквизитФормы("Объект", Новый ОписаниеТипов(ТипНовогоОбъекта));
	НовыйРеквизит.СохраняемыеДанные = Истина;
	
	ДобавляемыеРеквизиты = Новый Массив;
	ДобавляемыеРеквизиты.Добавить(НовыйРеквизит);
	
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	ЗначениеВРеквизитФормы(НовыйОбъект, "Объект");
	
	Для каждого Элемент Из Элементы Цикл
		Если ТипЗнч(Элемент) = Тип("ПолеФормы")
			И СтрНачинаетсяС(Элемент.ПутьКДанным, "ОбъектПрототип[0].")
			И СтрЗаканчиваетсяНа(Элемент.Имя, "0") Тогда
			
			ИмяЭлемента = Лев(Элемент.Имя, СтрДлина(Элемент.Имя) -1);
			Если Элементы.Найти(ИмяЭлемента) <> Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			НовыйЭлемент = Элементы.Вставить(ИмяЭлемента, ТипЗнч(Элемент), Элемент.Родитель, Элемент);
			НовыйЭлемент.ПутьКДанным = "Объект." + Сред(Элемент.ПутьКДанным, СтрДлина("ОбъектПрототип[0].") + 1);
			
			Если Элемент.Вид = ВидПоляФормы.ПолеНадписи Тогда
				ИсключаемыеСвойства = "Имя, ПутьКДанным";
			Иначе
				ИсключаемыеСвойства = "Имя, ПутьКДанным, ВыделенныйТекст, СвязьПоТипу";
			КонецЕсли;
			ЗаполнитьЗначенияСвойств(НовыйЭлемент, Элемент, , ИсключаемыеСвойства);
			
			Элемент.Видимость = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	СтатусСоздана = СтроковыеФункции.ФорматированнаяСтрока(НСтр("ru = '<a href=""%1"">%2</a>';
																|en = '<a href=""%1"">%2</a>'"),
		ПолучитьНавигационнуюСсылку(ЭтотОбъект["Объект"].Автор), Строка(ЭтотОбъект["Объект"].Автор));
	
	ОбновитьИнформациюОбИзменении();
	
	Если Параметры.Свойство("Родитель") Тогда
		НовыйОбъект.Родитель = Параметры.Родитель;
	КонецЕсли;
	
	Если Не НовыйОбъект.ЭтоНовый() Тогда
		НавигационнаяСсылка = ПолучитьНавигационнуюСсылку(НовыйОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьЗаголовок()
	
	ТекущаяСсылкаНаФайл = ТекущаяСсылкаНаФайлСервер();
	Если ЗначениеЗаполнено(ТекущаяСсылкаНаФайл) Тогда
		Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 (Группа файлов)';
				|en = '%1 (File group)'"), Строка(ТекущаяСсылкаНаФайл));
	Иначе
		Заголовок = НСтр("ru = 'Группа файлов (Создание)';
						|en = 'File group (Create)'")
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ОбработатьКомандуЗаписиФайла()
	
	ОчиститьСообщения();
	
	Если ПустаяСтрока(ЭтотОбъект.Объект.Наименование) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Для продолжения укажите имя файла.';
				|en = 'To proceed, please provide the file name.'"), , "Наименование", "Объект");
		Возврат Ложь;
	КонецЕсли;
	
	Попытка
		РаботаСФайламиСлужебныйКлиент.КорректноеИмяФайла(ЭтотОбъект.Объект.Наименование);
	Исключение
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()), ,"Наименование", "Объект");
		Возврат Ложь;
	КонецПопытки;
	
	Если НЕ ЗаписатьФайл() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Модифицированность = Ложь;
	ОтобразитьИзменениеДанных(ЭтотОбъект.Объект.Ссылка, ВидИзмененияДанных.Изменение);
	ОповеститьОбИзменении(ЭтотОбъект.Объект.Ссылка);
	Оповестить("Запись_Файл", Новый Структура("ЭтоНовый", ФайлБылСоздан), ЭтотОбъект.Объект.Ссылка);
	
	Возврат Истина;
	
КонецФункции

&НаКлиенте
Функция ЭтоНовый()
	
	Возврат ТекущаяСсылкаНаФайл().Пустая();
	
КонецФункции

&НаСервере
Функция ЗаписатьФайл(Знач ПараметрОбъект = Неопределено)
	
	Если ПараметрОбъект = Неопределено Тогда
		ЗаписываемыйОбъект = РеквизитФормыВЗначение("Объект"); //СправочникОбъект
	Иначе
		ЗаписываемыйОбъект = ПараметрОбъект;
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		ЗаписываемыйОбъект.Изменил                      = Пользователи.АвторизованныйПользователь();
		ЗаписываемыйОбъект.ДатаМодификацииУниверсальная = ТекущаяУниверсальнаяДата();
		ЗаписываемыйОбъект.Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
		
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Файлы.Ошибка записи группы присоединенных файлов';
										|en = 'Files.Error writing group of attachments'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка,,, ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()) );
		ВызватьИсключение;
		
	КонецПопытки;
	
	Если ПараметрОбъект = Неопределено Тогда
		ЗначениеВРеквизитФормы(ЗаписываемыйОбъект, "Объект");
	КонецЕсли;
	
	ОбновитьЗаголовок();
	ОбновитьИнформациюОбИзменении();
	
	Возврат Истина;
	
КонецФункции

&НаКлиенте
Процедура СтандартнаяПеречитатьОтветПолучен(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		ПеречитатьДанныеССервера();
		Модифицированность = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПеречитатьДанныеССервера()
	
	ФайлОбъект = ТекущаяСсылкаНаФайлСервер().ПолучитьОбъект();
	ЗначениеВРеквизитФормы(ФайлОбъект, "Объект");
	
	ОбновитьИнформациюОбИзменении();

КонецПроцедуры

&НаСервере
Процедура ОбновитьИнформациюОбИзменении()
	
	СтатусИзменена = СтроковыеФункции.ФорматированнаяСтрока(НСтр("ru = '<a href=""%1"">%2</a>';
																|en = '<a href=""%1"">%2</a>'"),
		ПолучитьНавигационнуюСсылку(ЭтотОбъект["Объект"].Изменил), Строка(ЭтотОбъект["Объект"].Изменил));
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьФормуПослеОтветаНаВопрос(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да
		И ОбработатьКомандуЗаписиФайла() Тогда
		Закрыть();
	ИначеЕсли Ответ = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ТекущаяСсылкаНаФайл()
	
	ОбъектФормы = ЭтотОбъект.Объект; // СправочникОбъект
	Возврат ОбъектФормы.Ссылка;
	
КонецФункции

&НаСервере
Функция ТекущаяСсылкаНаФайлСервер()

	ОбъектФормы = ЭтотОбъект.Объект; // СправочникОбъект
	Возврат ОбъектФормы.Ссылка;

КонецФункции

#КонецОбласти