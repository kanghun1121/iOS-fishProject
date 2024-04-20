import Foundation

struct WeatherInfo: Codable {
    let response: Response
}

// MARK: - Response
struct Response: Codable {
    let body: Body
}

// MARK: - Body
struct Body: Codable {
    let items: Items
}

// MARK: - Items
struct Items: Codable {
    let item: [Item]
}

// MARK: - Item
struct Item: Codable {
    let category, fcstDate: String
    let fcstTime, fcstValue: String
}

// 내가 사용할 데이터 (사용자 정의)
struct Weather {
    let predictDate : Date
    let category : String
    let categoryValue : String
    
    init(predictDate : Date, category : String, categoryValue : String) {
        self.predictDate = predictDate
        self.category = category
        self.categoryValue = categoryValue
    }
}

struct WeatherDataManager {
    
    let weatherURL = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst?"
    
    let myKey = "6E9dEW%2Fb3b5ERqqLtxCK%2F9YKwHH%2Bmpx7C7JFZO6Tttpixa1CEPx3Zbg2btVMEU1ijqseENJpVuGzau0hbLo7qg%3D%3D"
    
    func getCurrentTime() -> (String, String) {
        // 현재 시간을 기준으로 바로 시간을 뿌려주는게 아니라 이전 시간의 30분 기준으로 뿌려줘야 하는 로직을 생성해줘야 함⭐️⭐️⭐️
        
        let tempTimeArray = ["0030","0130","0230","0330","0430","0530","0630","0730","0830","0930","1030","1130","1230","1330","1430","1530","1630","1730","1830","1930","2030","2130","2230","2330"]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let current_date_string = formatter.string(from: Date())
        
        let dateString = current_date_string.components(separatedBy: " ")
        var (currentDate, currentTime) = (dateString[0], dateString[1])
        
        currentDate = currentDate.components(separatedBy: "-").joined()
        currentTime = currentTime.components(separatedBy: ":").joined()
        
        let currentIntTIme = Int(currentTime)!
        
        var temp_idx = 0
        
        for (idx, value) in tempTimeArray.enumerated() {
            if (Int(value)! - currentIntTIme > 0) {
                if (idx - 1 < 0) {
                    temp_idx = 23
                    break
                }
                temp_idx = (idx - 1)
                break
            }
        }
        
        return (currentDate, String(tempTimeArray[temp_idx]))
    }
    
    // 비동기적 실행이기 때문에 @escaping 작성.
    func fetchMovie(currentDate : String, currentTime : String, cur_x : String, cur_y : String, completion: @escaping ([Weather]?) -> Void) {
        let urlString = "\(weatherURL)servicekey=\(myKey)&pageNo=1&numOfRows=1000&dataType=JSON&base_date=\(currentDate)&base_time=\(currentTime)&nx=\(cur_x)&ny=\(cur_y)"
        performRequest(with: urlString) { weathers in
            completion(weathers)
        }
    }
    
    func performRequest(with urlString : String, completion : @escaping ([Weather]?) -> Void) {
        
        guard let url = URL(string : urlString) else { return }

        let session = URLSession.shared

        let task = session.dataTask(with: url) { data, response, error in
            
            guard error == nil else {
                print(error!)
                completion(nil)
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else { // ~= 범위체크 연산자
                print("Error : HTTP request failed")
                completion(nil)
                return
            }
            
            guard let safeData = data else {
                completion(nil)
                return
            }
            
            if let weathers = self.parseJSON(safeData) {
                completion(weathers)
            }
            else {
                completion(nil)
            }
        }

        task.resume()
    }
    
    func check_category(_ category : String) -> Bool {
        // T1H SKY WSD RN1
        if (category == "T1H") {
            return false
        }
        if (category == "SKY") {
            return false
        }
        if (category == "WSD") {
            return false
        }
        if (category == "RN1") {
            return false
        }
        
        return true
    }
    
    func parseJSON(_ weatherData : Data) -> [Weather]? {

        do {
            let decoder = JSONDecoder()

            let decodedData = try decoder.decode(WeatherInfo.self, from: weatherData)
            
            let temp_data = decodedData.response.body.items.item
            
            var weatherList = [Weather]()
            
            for weather in temp_data {
                
                if (check_category(weather.category)) { continue } // category 체크
                
                let temp_date = weather.fcstDate.map { String($0) }
                let temp_time = weather.fcstTime.map { String($0) }
                
                let dateComp = DateComponents(year : Int(temp_date[0...3].joined()), month : Int(temp_date[4...5].joined()), day : Int(temp_date[6...7].joined()), hour : Int(temp_time[0...1].joined()))
                
                // 한국시간으로 변경
                let dateValue = Calendar.current.date(from: dateComp)
                
                guard let dateValue = dateValue else {
                    print("날짜 시간 변경에서 문제 발생했습니다.")
                    return nil
                }
                
                let timezone = TimeZone.autoupdatingCurrent
                let secondsFromGMT = timezone.secondsFromGMT(for: dateValue)
                let localizedDate = dateValue.addingTimeInterval(TimeInterval(secondsFromGMT))
                
                let weatherInfo = Weather(predictDate: localizedDate, category: weather.category, categoryValue: weather.fcstValue)
                
                weatherList.append(weatherInfo)
            }

            // weatherList Date 시간별로 Sort 구현
            let sortedWeatherList = weatherList.sorted {
                $0.predictDate < $1.predictDate
            }
            
            
            return sortedWeatherList

        }
        catch {
            print("파싱 실패")
            return nil
        }
    }
}



