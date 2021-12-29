import Foundation

class macOSSpeechObject {
    private var voiceList: String
    private var rate: Int
    private var specifiedVoice: String
    private var status: String
    private var error: String

    init(voiceList: String = "", rate: Int = 180, specifiedVoice: String = "", repeatAnswer: Bool = false) {
        status = "Wait for initSpeakingMode"
        error = ""
        self.voiceList = voiceList
        self.rate = rate
        self.specifiedVoice = specifiedVoice
    }

    private func execute(command: String, args: [String]) -> String {
        let task = Process()

        task.launchPath = command
        task.arguments = args

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return output
    }

    private func speak(_ strings: [String]) -> String {
        if status == "Wait for initSpeakingMode" {
            return "ERROR #1 : You haven't initSpeakingMode yet"
        }
        var str = strings
        str.append("-v")
        str.append(specifiedVoice)
        str.append("-r")
        str.append(String(rate))
        if voiceList != "" {
            status = "speak " + strings.joined(separator: " ")
            return execute(command: "/usr/bin/say", args: str)
        } else {
            return "ERROR #2 : Empty Voice List"
        }
    }

    func initSpeakingMode(canSay: Bool = false, string: String = "hi there") -> Bool {
        if !FileManager.default.fileExists(atPath: "/usr/bin/say") {
            return false
        }
        if canSay {
            _ = speak([string])
        }
        voiceList = speak(["-v", "?"])
        if voiceList == "" {
            return false
        }
        status = "Finish initSpeakingMode"
        return true
    }

    func say(_ str: String, withrate: Int = 180, withVoice: String = "") {
        let lastrate = rate
        let lastVoice = withVoice
        setSpeakingrate(to: withrate)
        setSpecifiedVoice(to: withVoice)
        _ = speak([str])
        setSpeakingrate(to: lastrate)
        setSpecifiedVoice(to: lastVoice)
    }

    // setter
    func updateVoiceList(with: String) {
        voiceList = with
    }

    func setSpeakingrate(to: Int) {
        rate = to
    }

    func setSpecifiedVoice(to: String) {
        specifiedVoice = to
    }

    // getter
    func getVoiceList() -> String {
        return voiceList
    }

    func getSpeackrate() -> Int {
        return rate
    }

    func getSpecifiedVoice() -> String {
        return specifiedVoice
    }

    func getError() -> String {
        return error
    }
    
    func getStatus() -> String {
        return status
    }
    
    // explain the errors
    func explainError(withCode: Int) -> String {
        switch withCode {
        case 1:
            return "You need to initSpeakingMode to using the speak() function, the initSpeakingMode() function will looking for the voice list on your device so that you can choose a specified voice to speak"
        case 2:
            return "This happen when the program cannot find any voice that have installed on your devices, please check it"
        default:
            return "Unknow error code???"
        }
    }
}

var me = macOSSpeechObject()

_ = me.initSpeakingMode()
me.say("Hello",withVoice: "victoria")
