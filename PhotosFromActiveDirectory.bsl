// Обработка выгружает из ActiveDirectory фотографии пользователей. Можно выгрузить превьюшки - thumbnailPhoto. Таких примеров много
// в интернете. А можно выгрузить большие фотографии - jpegPhoto. Примера выгрузки больших фотографий в интернете на момент создания
// обработки не было. А вся разница в том, что jpegPhoto возвращается в виде вложенного массива ComSafeArray - массив ComSafeArray
// внутри еще одного массива ComSafeArray. Поэтому в отличие от превьюшки надо сначала достать вложенный массив а дальше сохранить его
// потоком как и превьюшку.

&НаКлиенте
Процедура ПолучитьИнфо(Команда)
	
  // не надо писать "МойДомен.local". Просто "МойДомен". "local" уже встроено в путь.
	ПолучитьИнфоНаСервере("МойДомен");
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьИнфоНаСервере(ИмяДомена)

	Попытка
		Connection = ПолучитьCOMОбъект("","ADODB.Connection");
		Connection.Provider = "ADSDSOObject";
		Connection.Open("Active Directory Provider");
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат;
	КонецПопытки;
	
	Попытка
		
		// получаем превьюшки фото из домена
		//query = "SELECT Name, thumbnailPhoto FROM 'LDAP://DC=" + ИмяДомена + ",DC=local' WHERE objectCategory='User'";
		
		// получаем большие фото из домена
		query = "SELECT Name, jpegPhoto FROM 'LDAP://DC=" + ИмяДомена + ",DC=local' WHERE objectCategory='User'";
		rs = Connection.Execute(query);
		Пока НЕ rs.EOF Цикл
			
			ПолноеИмя = rs.Fields("Name").Value;
			
			//Если НЕ rs.Fields("thumbnailPhoto").Value = Null Тогда
			Если НЕ rs.Fields("jpegPhoto").Value = Null Тогда
				
				// фото возвращаются в массиве ComSafeArray, преобразуем их
				Поток         = Новый COMОбъект("ADODB.Stream");
				Поток.Type     = 1;
		
				Поток.Mode     = 3;
				Поток.Open();
				// большое фото в отличие от превьюшки помещено во вложенный массив ComSafeArray, поэтому надо его
				// сначала получить - .GetValue(0)
				Поток.Write(rs.Fields("jpegPhoto").Value.GetValue(0));
				
				//превьюшка сохраняется сразу
				//Поток.Write(rs.Fields("thumbnailPhoto").Value);
				Поток.SaveToFile("F:\photos\" + ПолноеИмя + ".jpg");
				Поток.Close();
				
			КонецЕсли;
			rs.MoveNext();
		КонецЦикла;	
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
	Connection.Close();
	
КонецПроцедуры
