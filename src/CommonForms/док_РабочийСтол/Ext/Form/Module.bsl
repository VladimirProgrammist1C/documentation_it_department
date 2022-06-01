﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Пользователь = Пользователи.ТекущийПользователь();
	Если Пользователь.Пустая() ТОгда
		Элементы.Декорация1.Видимость = Ложь;
	Иначе	
		Элементы.Декорация1.Заголовок = "Приветствую, " + Строка(Пользователь) + "!";
	КонецЕсли;
	Элементы.ВвестиПарольДляРасшифровкиПаролей.Видимость = ПолучитьФункциональнуюОпцию("док_ШифроватьПароли");
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	#Если МобильныйКлиент Тогда
		Элементы.Группа1.ВертикальноеПоложениеПодчиненных = ВертикальноеПоложениеЭлемента.Низ;
		Элементы.Группа1.РастягиватьПоВертикали = Истина;
		Элементы.Группа11.Видимость = Истина;
	#КонецЕсли	
КонецПроцедуры

&НаКлиенте
Процедура БД(Команда)
	ОткрытьФорму("Справочник.док_БД.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Видеорегистраторы(Команда)
	ОткрытьФорму("Справочник.док_Видеорегистраторы.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Домены(Команда)
	ОткрытьФорму("Справочник.док_Домены.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Кассы(Команда)
	ОткрытьФорму("Справочник.док_Кассы.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Клиенты(Команда)
	ОткрытьФорму("Справочник.док_Клиенты.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Номенклатура(Команда)
	ОткрытьФорму("Справочник.док_Номенклатура.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура ОперационныеСистемы(Команда)
	ОткрытьФорму("Справочник.ОперационныеСистемы.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Принтеры(Команда)
	ОткрытьФорму("Справочник.док_Принтеры.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Серверы(Команда)
	ОткрытьФорму("Справочник.док_Серверы.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура СУБД(Команда)
	ОткрытьФорму("Справочник.док_СУБД.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Выход(Команда)
	ЗавершитьРаботуСистемы(Ложь,Ложь);
КонецПроцедуры

&НаКлиенте
Процедура Настройки(Команда)
	ОткрытьФорму("ОбщаяФорма.док_Настройки");
КонецПроцедуры

&НаКлиенте
Процедура Заметки(Команда)
	ОткрытьФорму("Справочник.Заметки.Форма.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Slack(Команда)
	ОткрытьФорму("Обработка.док_ПанельВзаимодействия.Форма.Slack");
КонецПроцедуры

&НаКлиенте
Процедура Файлы(Команда)
	ОткрытьФорму("Справочник.Файлы.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура УчетныеДанные(Команда)
	ОткрытьФорму("Справочник.док_УчетныеДанныеСервисов.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Сервисы(Команда)
	ОткрытьФорму("Справочник.док_Сервисы.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура СетевоеОборудование(Команда)
	ОткрытьФорму("Справочник.док_СетевоеОборудование.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Устройства(Команда)
	ОткрытьФорму("Справочник.док_Устройства.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура СерверыVPN(Команда)
	ОткрытьФорму("Справочник.док_СерверыVPN.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Сети(Команда)
	ОткрытьФорму("Справочник.док_Сети.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура УстройстваСУдаленнымУправлением(Команда)
	ОткрытьФорму("Справочник.док_УстройстваСУдаленнымУправлением.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура ВвестиПарольДляРасшифровкиПаролей(Команда)
	Оповещение = Новый ОписаниеОповещения("ПослеВводаПароля",ЭтаФорма);
	Пароль = "";
	ПоказатьВводСтроки(Оповещение,Пароль,"Введите пароль",100,Ложь);	
КонецПроцедуры

&НаКлиенте
Процедура ПослеВводаПароля(Пароль, параметры) Экспорт
	Если НЕ Пароль = "" Тогда
		док_ШифрованиеДанныхКлиент.УстановитьПараметрСеансаСПаролем(Пароль);
	КонецЕсли;		
КонецПроцедуры