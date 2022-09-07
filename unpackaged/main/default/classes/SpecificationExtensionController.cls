public class SpecificationExtensionController{
	private final Contract contract;    
    private final Contract contract_full;
    public Specification__c specification;
    private final ApexPages.StandardController stdController;
    
    Map <Integer,String> monthNames = new Map<Integer,String> {1 => 'января',2 => 'февраля',3 => 'марта',
        4 => 'апреля', 5 => 'мая', 6 => 'июня', 7 => 'июля', 8 => 'августа', 9 => 'сентября', 10 => 'октября',
        11 => 'ноября', 12 => 'декабря'};
            
    Map <Integer,String> text_1_r = new Map<Integer,String> {1 => 'одного',2 => 'двух',3 => 'трех',
        4 => 'четырех', 5 => 'пяти', 6 => 'шести', 7 => 'семи', 8 => 'восьми', 9 => 'девяти'};
    Map <Integer,String> text_10_r = new Map<Integer,String> {1 => 'десяти',2 => 'двадцати',3 => 'тридцати',
        4 => 'сорока', 5 => 'пятидесяти', 6 => 'шестидесяти', 7 => 'семидесяти', 8 => 'восьмидесяти', 9 => 'девяноста'};
    Map <Integer,String> text_1020_r = new Map<Integer,String> {11 => 'одиннадцати',12 => 'двенадцати',13 => 'тринадцати',
        14 => 'четырнадцати', 15 => 'пятнадцати', 16 => 'шестнадцати', 17 => 'семнадцати', 18 => 'восемнадцати', 19 => 'девятнадцати'};
            
    Map <Integer,String> text_1_m = new Map<Integer,String> {1 => 'один',2 => 'два',3 => 'три',
        4 => 'четыре', 5 => 'пять', 6 => 'шесть', 7 => 'семь', 8 => 'восемь', 9 => 'девять'};
    Map <Integer,String> text_1_f = new Map<Integer,String> {1 => 'одна',2 => 'две',3 => 'три',
        4 => 'четыре', 5 => 'пять', 6 => 'шесть', 7 => 'семь', 8 => 'восемь', 9 => 'девять'};
    Map <Integer,String> text_1020 = new Map<Integer,String> {11 => 'одиннадцать',12 => 'двенадцать',13 => 'тринадцать',
        14 => 'четырнадцать', 15 => 'пятнадцать', 16 => 'шестнадцать', 17 => 'семнадцать', 18 => 'восемнадцать', 19 => 'девятнадцать'};
    Map <Integer,String> text_10 = new Map<Integer,String> {1 => 'десять',2 => 'двадцать',3 => 'тридцать',
        4 => 'сорок', 5 => 'пятьдесят', 6 => 'шестьдесят', 7 => 'семьдесят', 8 => 'восемьдесят', 9 => 'девяносто'};
    Map <Integer,String> text_100 = new Map<Integer,String> {1 => 'сто',2 => 'двести',3 => 'триста',
        4 => 'четыреста', 5 => 'пятьсот', 6 => 'шестьсот', 7 => 'семьсот', 8 => 'восемьсот', 9 => 'девятьсот'};

    public Integer specConditionPointNumber = 1;
    public Decimal contractNDS = 0;
    public Decimal contractTotal = 0;
    public Decimal contractCount = 0;
    public Decimal contractTotalWithoutNDS = 0;
    
    public Decimal contractNDSpre = 0;
    public Decimal contractTotalpre = 0;
    
    public Decimal contractNDSpart = 0;
    public Decimal contractTotalpart = 0;
    
    public Decimal contractNDSpost = 0;
    public Decimal contractTotalpost = 0;
    
    private class ContractProduct {
        public String name {get;set;}
        public Decimal quantity {get;set;}
        public Decimal unitprice {get;set;}
        public Decimal unitpriceWithoutNDS {get;set;}        
        public Decimal unitNDS {get;set;}      
        public String unitNDSString {get;set;}
        public Decimal subtotal {get;set;}
        public Decimal subtotalWithoutNDS {get;set;}            
        public Decimal subtotalNDS {get;set;}           
        public Decimal NDS {get;set;}    
    }
    
    public void getCProduct(){
        new ContractProduct();   
    }
        
    public SpecificationExtensionController (ApexPages.StandardController controller) {
        stdController = controller;
        specification = (Specification__c) controller.getRecord();
        specification = [select ID, Contract__c, SpecificationDate__c, Quote__c,
                         			PrePayment__c, PartPayment__c, PostPayment__c,InvoiceReadyInfo__c,
                         			PrePayment_days__c, PartPayment_days__c, PostPayment_days__c,
                         			SpecificationType__c, SpecificationNumber__c,CompanyDeliverTo__c,
                         			DeliveryCondition__c, DeliveryAddress__c, Repository__c, PaymentDelayText__c
                         	FROM Specification__c WHERE ID =:specification.ID];
        
        contract_full = [select prepayment__c,prepayment_days__c,partpayment__c,
                                partpayment_days__c,postpayment__c,postpayment_days__c,
                                SpecificationType__c, SpecificationNumber__c, DeliveryCondition__c, Repository__c,
                                CompanyDeliverTo__c, DeliveryAddress__c,PaymentDelayText__c,
                                InvoiceReadyInfo__c, ContractNumber__c, StartDate,ShortBillingContractorName__c,
                         		SignerPosition__c,TionPersonToSignContract__c,SignatureInitials__c 
                         from Contract where 
                         Id=:specification.Contract__c];
        contract = contract_full;
    }
    
    public Contract getContract(){
     	return Contract;   
    }
    
    public string getContractDate() {
        String day = contract.StartDate.day().format();
        if(day.length()==1) {
            day = '0'+day;
        }
        String contractDate = '«'+ day +'» '+monthNames.get(contract.StartDate.month())+' '+contract.StartDate.year()+' г.';
        return contractDate;
    }
    
    public string getContractSpecificationDate() {
        String day = specification.SpecificationDate__c.day().format();
        if(day.length()==1) {
            day = '0'+day;
        }
        String contractDate = '«'+ day +'» '+monthNames.get(specification.SpecificationDate__c.month())+' '+specification.SpecificationDate__c.year()+' г.';
        return contractDate;
    }
    
    public List<ContractProduct> getContractProducts() {
        List<ContractProduct> contractProducts = new List<ContractProduct>();
        Id quoteId = specification.Quote__c;
        List<QuoteLineItem> qProducts = [select PricebookEntry.Product2.name, quantity, unitprice, discount, subtotal, 
                                            SectionComposition__c, SideOfService__c, isSpecialEdition__c,isOutdoor__c,
                                            RecirculationModule__c from QuoteLineItem where quoteId=:quoteId];
        for(QuoteLineItem oli: qProducts) {
            ContractProduct contProd = new ContractProduct();
            contProd.name = oli.PricebookEntry.Product2.name;
            String nameSuffix = '';
            if(contProd.name.endsWith('Мед')) {
                contProd.name = contProd.name.removeEnd('Мед');
                nameSuffix = ' МЕД';
            } else if(contProd.name.endsWith('Пром')) {
                contProd.name = contProd.name.removeEnd('Пром');
                nameSuffix = ' Пром';
            } else {
            }
            if(oli.SectionComposition__c != null) contProd.name += ' ' + oli.SectionComposition__c;
            if(oli.SideOfService__c != null) contProd.name += ' ' + oli.SideOfService__c;
            if(oli.isSpecialEdition__c == 'Да') contProd.name += ' -S';
            if(oli.isOutdoor__c == 'Да') contProd.name += ' -O';
            if(oli.RecirculationModule__c == 'Да') contProd.name += ' -R';
            contProd.name += nameSuffix;

            contProd.quantity = oli.quantity;
            if(oli.discount != null){
                contProd.unitprice = oli.unitprice - oli.unitprice*oli.discount/100.0;
            } else {
                contProd.unitprice = oli.unitprice;
            }
            contProd.unitprice = contProd.unitprice.setScale(2,System.RoundingMode.HALF_UP);
            if(contProd.name.toUpperCase().indexOf('МЕД', 0) >= 0){
                contProd.unitNDSString = 'Без НДС';
                contProd.NDS = 0;
            }
            else{
                //contProd.unitpriceWithoutNDS = (contProd.unitprice/118*100).setScale(2,System.RoundingMode.HALF_UP);
                //contProd.unitNDS = (contProd.unitprice - contProd.unitpriceWithoutNDS).setScale(2,System.RoundingMode.HALF_UP);
                       
                contProd.unitNDSString = '18%';
                contProd.NDS = 18;
            }
            
            if(contract.SpecificationType__c == 'Экспорт') {
                contProd.unitNDSString = '0%';     
                contProd.NDS = 0;
            }           
            
            contProd.subtotal = (contProd.quantity * contProd.unitprice).setScale(2,System.RoundingMode.HALF_UP);
            contProd.subtotalNDS = (contProd.subtotal*contProd.NDS/118).setScale(2,System.RoundingMode.HALF_UP);
            
            contProd.subtotalWithoutNDS = contProd.subtotal - contProd.subtotalNDS;
            contProd.unitpriceWithoutNDS = (contProd.subtotalWithoutNDS / contProd.quantity).setScale(2,System.RoundingMode.HALF_UP);
            
            contractNDS += contProd.subtotalNDS;
            contractTotal += contProd.subtotal;
            contractCount += contProd.quantity;
            contractTotalWithoutNDS += contProd.subtotalWithoutNDS;
            contractProducts.add(contProd);
        }    
        
        contractTotalpre = (contractTotal * specification.PrePayment__c/100).setScale(2,System.RoundingMode.HALF_UP);
        contractNDSpre = (contractTotalpre * 18 / 118).setScale(2,System.RoundingMode.HALF_UP);
        contractTotalpart = (contractTotal * specification.PartPayment__c/100).setScale(2,System.RoundingMode.HALF_UP);
        contractNDSpart = (contractTotalpart * 18 / 118).setScale(2,System.RoundingMode.HALF_UP);
        contractTotalpost = (contractTotal * specification.PostPayment__c/100).setScale(2,System.RoundingMode.HALF_UP);
        contractNDSpost = (contractTotalpost * 18 / 118).setScale(2,System.RoundingMode.HALF_UP);
        
        if(contractTotalpre + contractTotalpart + contractTotalpost != contractTotal){
            if(contractTotalpost != 0) contractTotalpost = contractTotal - (contractTotalpre + contractTotalpart);
            else if(contractTotalpart != 0) contractTotalpart = contractTotal - (contractTotalpre + contractTotalpost);  
            else contractTotalpre = contractTotal - (contractTotalpart + contractTotalpost);
        }
        if(contractNDSpre + contractNDSpart + contractNDSpost != contractNDS){
            if(contractNDSpost != 0) contractNDSpost = contractNDS - (contractNDSpre + contractNDSpart);
            else if(contractNDSpart != 0) contractNDSpart = contractNDS - (contractNDSpre + contractNDSpost);  
            else contractNDSpre = contractNDS - (contractNDSpart + contractNDSpost);
        }
        return contractProducts;
    }
    
    public String getContractNDS() {
        return contractNDS.toPlainString();
    }
    public Decimal getContractCount() {
        return contractCount;
    }
    
    public String getContractTotal() {
        return contractTotal.toPlainString();
    }
    
    public String getContractTotalWithoutNDS() {
        return contractTotalWithoutNDS.toPlainString();
    }
    
    
    public String getContractTotalStr() {
        return num2str(contractTotal);
    }
    
    public String getContractNDSStr() {
        return num2str(contractNDS);
    }
    
    public String getPaymentText() {
        String Text = '';
        String NDS = '';
        if(specification.PostPayment__c == 100 || specification.PartPayment__c == 100 || specification.PrePayment__c == 100){
            if(specConditionPointNumber == 1){                             
                if(specification.SpecificationType__c == 'Экспорт') NDS = 'в том числе НДС 0%';
                else if(ContractNDS > 0) NDS = 'в том числе НДС ' + num2str(ContractNDS);
                else NDS = 'без НДС';
                if(specification.PrePayment__c == 100){
                    Text = '2.' + specConditionPointNumber + '. ' +' Покупатель производит предоплату в размере 100% от суммы стоимости '+
                        'поставляемого Поставщиком Оборудования, указанного в настоящей Спецификации, а именно '+num2str(ContractTotal)+', '+NDS+',  '+
                        'в течение ' + getBankDaysStr(specification.PrePayment_days__c) + ' с момента подписания настоящей Спецификации обеими сторонами, ' +
                        'путем перечисления безналичных денежных средств на расчетный счет Поставщика.';
                }
                else if(specification.PartPayment__c == 100){
                    Text = '2.' + specConditionPointNumber + '. ' +' Покупатель производит оплату в размере 100% от суммы стоимости '+
                        'поставляемого Поставщиком Оборудования, указанного в настоящей Спецификации, а именно '+num2str(ContractTotal)+', '+NDS+',  '+
                        'в течение ' + getBankDaysStr(specification.PartPayment_days__c) + ' с момента предоставления Поставщиком письменного уведомления Покупателя о готовности Оборудования к отгрузке со склада ' + contract_full.InvoiceReadyInfo__c + ', ' +
                        'путем перечисления безналичных денежных средств на расчетный счет Поставщика.';
                }
                else if(specification.PostPayment__c == 100){
                    Text = '2.' + specConditionPointNumber + '. ' +' Покупатель производит оплату в размере 100% от суммы стоимости '+
                        'поставляемого Поставщиком Оборудования, указанного в настоящей Спецификации, а именно '+num2str(ContractTotal)+', '+NDS+',  '+
                        'в течение ' + getBankDaysStr(specification.PostPayment_days__c) + ' с даты подписания Сторонами товарной накладной, ' +
                        'путем перечисления безналичных денежных средств на расчетный счет Поставщика.';
                }
                specConditionPointNumber += 1;
            }  
            return Text;   
        }
        else{
            if(specification.PrePayment__c > 0 && specConditionPointNumber == 1){
                if(specification.SpecificationType__c == 'Экспорт') NDS = 'в том числе НДС 0%';
                else if(ContractNDS > 0) NDS = 'в том числе НДС ' + num2str(ContractNDSpre);
                else NDS = 'без НДС';
                Text = '2.' + specConditionPointNumber + '. ' +
                    'Покупатель производит предоплату в размере '+(specification.PrePayment__c).setScale(0)+'% от суммы стоимости поставляемого Поставщиком Оборудования, '+
                    'указанного в настоящей Спецификации, а именно '+num2str(ContractTotalpre)+', '+NDS+',  '+
                    'в течение ' + getBankDaysStr(specification.PrePayment_days__c) + ' с момента подписания настоящей Спецификации обеими сторонами, '+
                    'путем перечисления безналичных денежных средств на расчетный счет Поставщика.';
                specConditionPointNumber += 1;
                return Text;
            }
            else if(specification.PrePayment__c == 0 && specConditionPointNumber != 1){
                return Text;
            }
            else{
                if(specification.PostPayment__c > 0){
                    if(specification.SpecificationType__c == 'Экспорт') NDS = 'в том числе НДС 0%';
                    else if(ContractNDS > 0) NDS = 'в том числе НДС ' + num2str(ContractNDSpost);
                    else NDS = 'без НДС';
                    Text = 'Окончательный расчет за Оборудование в размере '+(specification.PostPayment__c).setScale(0)+'% от суммы стоимости Оборудования, '+
                        'а именно '+num2str(ContractTotalpost)+', '+NDS+'  '+
                        ' - в течение ' + getBankDaysStr(specification.PostPayment_days__c) + ' после поставки Оборудования Покупателю (или указанному им грузополучателю) и подписания товарной накладной на Оборудование.';   
                }
                if(specification.PartPayment__c > 0){                    
                    if(specification.SpecificationType__c == 'Экспорт') NDS = 'в том числе НДС 0%';
                    else if(ContractNDS > 0) NDS = 'в том числе НДС ' + num2str(ContractNDSpart);
                    else NDS = 'без НДС';
                    String preText = 'Окончательный расчет за Оборудование в размере ';
                    if(Text.length() > 0) preText = 'Часть стоимости Оборудования в размере ';
                    Text = preText + (specification.PartPayment__c).setScale(0)+'% от суммы стоимости Оборудования, '+
                        'а именно '+num2str(ContractTotalpart)+', '+NDS+',  '+
                        'подлежит оплате Покупателем в течение ' + getBankDaysStr(specification.PartPayment_days__c) + ' с момента предоставления Поставщиком письменного уведомления Покупателя '+
                        'о готовности Оборудования к отгрузке со склада ' + specification.InvoiceReadyInfo__c + '.</p><p>' + Text;
                }
                Text = '2.' + specConditionPointNumber +'. ' + Text;
            }
        }
        
      
        specConditionPointNumber += 1;
        return Text;
    }
    
    public String getPaymentText2() {
        return getPaymentText();   
    }
    
    public String getBankDaysStr(Decimal days){
        String days_str = days.setScale(0).toPlainString();
        String bdays_str = ' банковских дней';
        if(days == 1 || (days > 20 && String.valueOf(days.setScale(0)).reverse().substring(0,1) == '1')) bdays_str = ' банковского дня';
        if(days >= 11 && days <= 19){
            days_str =  text_1020_r.get(Integer.valueOf(days)); 
        }
        else if(days >= 1 && days <= 9){
            days_str = text_1_r.get(Integer.valueOf(days));   
        }
        else if(days >= 10 && days <= 99){
            String ed = '';
            if(String.valueOf(days.setScale(0)).reverse().substring(0,1) != '0') ed = ' ' + text_1_r.get(Integer.valueOf(String.valueOf(days.setScale(0)).reverse().substring(0,1)));
            days_str = text_10_r.get(Integer.valueOf(String.valueOf(days.setScale(0)).reverse().substring(1,2))) + ed;
        }
        if(days <= 0 || days >= 100) return String.valueOf(days.setScale(0)) + ' ' + bdays_str;   
        return String.valueOf(days.setScale(0)) + ' (' + days_str + ') ' + bdays_str;   
    }
    
    public String getDelivery() {
        String deliveryText = '';
        if(specification.DeliveryCondition__c == 'За счет Покупателя. Покупатель оплачивает счет от транспортной компании') {
        
            deliveryText = specConditionPointNumber + '. Доставка Оборудования до пункта поставки осуществляется за счет Покупателя. '+ 
                'Выбор Перевозчика для доставки Оборудования в адрес Покупателя осуществляется Поставщиком. Стоимость доставки не ' + 
                'входит в стоимость Оборудования и оплачивается Покупателем самостоятельно непосредственно Перевозчику в момент ' + 
                'получения Оборудования от Перевозчика в соответствии с тарифами Перевозчика. Обязательства Поставщика по ' + 
                'поставке Оборудования считаются исполненными с момента передачи Оборудования Перевозчику для доставки Покупателю.'; 
            specConditionPointNumber += 1;
        
        } else if(specification.DeliveryCondition__c == 'Самовывоз в течение 5 дней после уведомления') {
        
            deliveryText = specConditionPointNumber + '. Покупатель осуществляет самовывоз Оборудования со склада Производителя ' + 
                'не позднее 5 (пяти) рабочих дней после получения от Поставщика уведомления о готовности Оборудования к отгрузке ' + 
                'в письменном виде или посредством факсимильной связи. Склад Производителя находится по адресу: ' + specification.Repository__c + '.'; 
            specConditionPointNumber += 1;
        
        } else if(specification.DeliveryCondition__c == 'Поставщик доставляет своими силами. Стоимость доставки входит в стоимость Оборудования') {
        
            deliveryText = specConditionPointNumber + '. Поставщик обязуется доставить своими силами и средствами Оборудование на склад ' + 
                'Покупателя. Стоимость транспортных расходов входит в стоимость Оборудования.'; 
            specConditionPointNumber += 1;
        
        } else if(specification.DeliveryCondition__c == 'Поставщик обязуется доставить своими силами и средствами Оборудование до склада транспортной компании в городе') {
        
            deliveryText = specConditionPointNumber + '. Поставщик обязуется доставить своими силами и средствами Оборудование до склада транспортной компании в ' + specification.DeliveryAddress__c + '. Стоимость транспортных расходов входит в стоимость Оборудования.'; 
            specConditionPointNumber += 1;
        
        } else if(specification.DeliveryCondition__c == 'За счет Покупателя. Покупатель оплачивает счет от Тион') {
        
            deliveryText = specConditionPointNumber + '. Поставщик обязуется доставить Оборудование на склад Покупателя за счет ' +
                'Покупателя. Покупатель компенсирует Поставщику транспортные расходы по поставке Продукции на основании отдельно ' +
                'выставляемого счета в срок не более 5 (пяти) банковских дней с даты его выставления с приложением копий '+
                'транспортных документов.'; 
            specConditionPointNumber += 1;
        
        } 
        return deliveryText;
    }
    
    public string getDelayIf(){
        if(specification.Prepayment__c != 100) return '2.'+String.valueOf(getspecConditionPointNumber()+1)+'. В случае задержки перечисления денежных средств, в размере ' + specification.PaymentDelayText__c + ' за Оборудование, срок поставки Оборудования увеличивается соразмерно срокам такой задержки.';
        else return '';
    }
    
    public String getAddressPost(){
        if(specification.DeliveryCondition__c == 'Самовывоз в течение 5 дней после уведомления') 
            return 'Адрес пункта отгрузки: ' + specification.Repository__c + ', грузополучатель: '+ specification.CompanyDeliverTo__c;        
        else
            return 'Адрес пункта поставки: ' + specification.DeliveryAddress__c + ', грузополучатель: '+ specification.CompanyDeliverTo__c;
    }
    
    public Integer getspecConditionPointNumber(){
        Integer points = 3;
        if(contract_full.PrePayment__c > 0 && contract_full.PrePayment__c < 100) points = 4;
        return points;
    }
    
    public Integer getspecConditionPointNumberNext(){
        Integer points = getspecConditionPointNumber() + 2;
        if(contract_full.Prepayment__c == 100) points -= 1;
        return points;
    }
    
    public String num2str(Decimal summ){
        Integer max;
        summ = summ.setScale(2,System.RoundingMode.HALF_UP);
        String summ_str = String.valueOf(summ);
        String kop_str = summ_str.substringAfterLast('.');
        String rub_str = summ_str.substringBeforeLast('.');  
        String rub_text = '';        
        if(rub_str.length() < 3) max = rub_str.length();
        else max = 3;
        String ed_str = rub_str.reverse().substring(0,max).reverse();
        rub_text = 'рублей';
        if(Integer.valueOf(ed_str) <= 10 || Integer.valueOf(ed_str) >= 20){
            Integer ed_number = Integer.valueOf(ed_str.reverse().substring(0,1));
            if(ed_number == 1) rub_text = 'рубль';
            else if(ed_number >=2 && ed_number <=4) rub_text = 'рубля';
        }
        String ed_str_text = num2str_converter(Integer.valueOf(ed_str), '', '', '', true);      
        String ts_str = '';
        String ts_str_text = '';
        if(rub_str.length() > 3){
            if(rub_str.length() < 6) max = rub_str.length();
            else max = 6;
            ts_str = rub_str.reverse().substring(3,max).reverse();
            ts_str_text = num2str_converter(Integer.valueOf(ts_str), 'тысяча', 'тысячи', 'тысяч', false);
        }
        String mln_str = '';
        String mln_str_text = '';
        if(rub_str.length() > 6){            
            if(rub_str.length() < 9) max = rub_str.length();
            else max = 9;
            mln_str = rub_str.reverse().substring(6,max).reverse();
            mln_str_text = num2str_converter(Integer.valueOf(mln_str), 'миллион', 'миллиона', 'миллионов', true);
        }
        String mlr_str = '';
        String mlr_str_text = '';
        if(rub_str.length() > 9){            
            if(rub_str.length() < 12) max = rub_str.length();
            else max = 12;
            mlr_str = rub_str.reverse().substring(9,max).reverse();
            mlr_str_text = num2str_converter(Integer.valueOf(mlr_str), 'миллиард', 'миллиарда', 'миллиардов', true);
        }
        String kop_text = 'копеек';
        if(Integer.valueOf(kop_str) <= 10 || Integer.valueOf(kop_str) >= 20){
            Integer kop_number = Integer.valueOf(kop_str.reverse().substring(0,1));
            if(kop_number == 1) kop_text = 'копейка';
            else if(kop_number >=2 && kop_number <=4) kop_text = 'копейки';
        }
        String number_text = mlr_str_text + ' ' + mln_str_text + ' ' + ts_str_text + ' ' + ed_str_text;
        return mlr_str + ' ' + mln_str + ' ' + ts_str + ' ' + ed_str + ' ('+ number_text.trim() +') ' + rub_text + ' ' + kop_str + ' ' + kop_text;
    }
    
    public String num2str_converter(Integer value, String postfix_i, String postfix_r, String postfix_m, Boolean masculine){
        Map <Integer,String> text_1 = text_1_f;
        if(masculine == true) text_1 = text_1_m;
        String text = '';
        String postfix = postfix_m;
        if(String.valueOf(value).length() == 3){
            text += text_100.get(Integer.valueOf(String.valueOf(value).substring(0,1))) + ' ';
            value = Integer.valueOf(String.valueOf(value).substring(1,3));
        }
        if(value >= 11 && value <= 19){
            text +=  text_1020.get(Integer.valueOf(value));            
        }
        else{
            if(value >= 10){
                text += text_10.get(Integer.valueOf(String.valueOf(value).substring(0,1))) + ' ';
                value = Integer.valueOf(String.valueOf(value).substring(1,2));
            } 
            if(value >= 1 && value <= 9){
                text += text_1.get(value) + ' ';  
            }   
            if(value == 1) postfix = postfix_i;
            else if(value >=2 && value <=4) postfix = postfix_r;
        }
        return text + ' ' + postfix;
    }
}