import Foundation

struct CoastInfo: Codable {
    let result: Result
}

// MARK: - Result
struct Result: Codable {
    let meta: Meta
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let recordTime, tideLevel, waterTemp, salinity: String
    let airTemp, airPress, windDir, windSpeed: String
    let windGust: String
    
    enum CodingKeys: String, CodingKey {
        case recordTime = "record_time"
        case tideLevel = "tide_level"
        case waterTemp = "water_temp"
        case salinity = "Salinity"
        case airTemp = "air_temp"
        case airPress = "air_press"
        case windDir = "wind_dir"
        case windSpeed = "wind_speed"
        case windGust = "wind_gust"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let obsPostID, obsPostName, obsLat, obsLon: String

    enum CodingKeys: String, CodingKey {
        case obsPostID = "obs_post_id"
        case obsPostName = "obs_post_name"
        case obsLat = "obs_lat"
        case obsLon = "obs_lon"
    }
}

struct Coast {
    let recordTime : String
    let tideLevel : String // 조위
    let waterTemp : String // 수온
    let salinity : String // 염분
    let airTemp : String // 기온
    let airPress : String // 기압
    let windDir : String // 풍향
    let windSpeed : String // 풍속
    let windGust : String // 돌풍
    
    let obsLat : String // 경도
    let obsLon : String // 위도
    let obsPostName : String // 해안가 이름
    
    init(recordTime: String, tideLevel: String, waterTemp: String, salinity: String, airTemp: String, airPress: String, windDir: String, windSpeed: String, windGust: String, obsLat: String, obsLon: String, obsPostName: String) {
        self.recordTime = recordTime
        self.tideLevel = tideLevel
        self.waterTemp = waterTemp
        self.salinity = salinity
        self.airTemp = airTemp
        self.airPress = airPress
        self.windDir = windDir
        self.windSpeed = windSpeed
        self.windGust = windGust
        self.obsLat = obsLat
        self.obsLon = obsLon
        self.obsPostName = obsPostName
    }
}


struct CoastDataManager {
    
    static var coastList = [Coast]()
    
    let coastURL = "http://www.khoa.go.kr/api/oceangrid/tideObsRecent/search.do?"
    
    let myKey = "1IsctRKNB0OfgDcw92JRRg=="
    
    let coastCodeList = ["DT_0063", "DT_0032", "DT_0031", "DT_0029", "DT_0026", "DT_0049", "DT_0042", "DT_0019", "DT_0017", "DT_0065", "DT_0057", "DT_0062", "DT_0023", "DT_0007", "DT_0006", "DT_0025", "DT_0041", "DT_0005", "DT_0056", "DT_0061", "DT_0094", "DT_0010", "DT_0051", "DT_0022", "DT_0093", "DT_0012", "IE_0061", "DT_0008", "DT_0067", "DT_0037", "DT_0016", "DT_0092", "DT_0003", "DT_0044", "DT_0043", "IE_0062", "DT_0027", "DT_0039", "DT_0013", "DT_0020", "DT_0068", "IE_0060", "DT_0001", "DT_0052", "DT_0024", "DT_0004", "DT_0028", "DT_0021", "DT_0050", "DT_0014", "DT_0002", "DT_0091", "DT_0902", "DT_0066", "DT_0011", "DT_0035"]
    
    
    func getCoastData() -> [Coast] {
        return CoastDataManager.coastList
    }
    
    func setCoastData() {
        
        for coastCode in coastCodeList {
            fetchCoast(obsNumber: coastCode) { coast in
                guard let coast = coast else {
                    return
                }
                CoastDataManager.coastList.append(coast)
            }
        }
    }
    
    
    func fetchCoast(obsNumber : String,  completion : @escaping (Coast?) -> Void) {
        let urlString = "\(coastURL)ServiceKey=\(myKey)&ObsCode=\(obsNumber)&ResultType=json"
        performRequest(with: urlString) { coast in
            completion(coast)
        }
    }
    
    func performRequest(with urlString : String, completion : @escaping (Coast?) -> Void) {
           
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
               
               if let coast = self.parseJSON(safeData) {
                   completion(coast)
               }
               else {
                   completion(nil)
               }
           }

           task.resume()
       }
    
    func parseJSON(_ coastData : Data) -> Coast? {

        do {
            let decoder = JSONDecoder()

            let decodedData = try decoder.decode(CoastInfo.self, from: coastData)
            
            let tempMeta = decodedData.result.meta // lat, lon, 관측소 이름
            let tempData = decodedData.result.data // 해양기온
            
            let coast = Coast(recordTime: tempData.recordTime, tideLevel: tempData.tideLevel, waterTemp: tempData.waterTemp, salinity: tempData.salinity, airTemp: tempData.airTemp, airPress: tempData.airPress, windDir: tempData.windDir, windSpeed: tempData.windSpeed, windGust: tempData.windGust, obsLat: tempMeta.obsLat, obsLon: tempMeta.obsLon, obsPostName: tempMeta.obsPostName)
            
            return coast
        }
        
        catch {
            print("파싱 실패")
            return nil
        }
    }

}

let coastManager = CoastDataManager()

var coastList = [Coast]()

coastManager.setCoastData()

DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
    coastList = coastManager.getCoastData()
    dump(coastList)
}
