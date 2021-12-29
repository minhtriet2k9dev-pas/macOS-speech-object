import Foundation

class macOSSpeechObject {
    private var voiceList: String
    private var speed: Int
    private var specifiedVoice: String
    private var repeatAnswer: Bool
    private var status: String
    private var error: String

    init(voiceList: String = "", speed: Int = 180, specifiedVoice: String = "alex", repeatAnswer: Bool = false) {
        status = "Wait for setup"
        error = ""
        self.voiceList = voiceList
        self.speed = speed
        self.specifiedVoice = specifiedVoice
        self.repeatAnswer = repeatAnswer
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

    private func say(_ strings: [String]) -> String {
        if status == "Wait for setup" {
            return "ERROR #1 : You haven't setup yet"
        }
        var str = strings
        str.append("-v")
        str.append(specifiedVoice)
        str.append("-r")
        str.append(String(speed))
        if voiceList != "" {
            status = "say " + strings.joined(separator: " ")
            return execute(command: "/usr/bin/say", args: str)
        } else {
            return "ERROR #2 : Empty Voice List"
        }
    }

    func setup(canSay: Bool = false, string: String = "hi there") -> Bool {
        if !FileManager.default.fileExists(atPath: "/usr/bin/say") {
            return false
        }
        if canSay {
            _ = say([string])
        }
        voiceList = say(["-v", "?"])
        if voiceList == "" {
            return false
        }
        status = "Finish setup"
        return true
    }

    func speak(_ str: String) {
        _ = say([str])
    }

    func getInput(_ prompt: String) {
        print(prompt)
        speak(prompt)
        if let command = readLine() {
            if repeatAnswer {
                speak("you enter " + command)
            }
        }
    }

    // setter
    func updateVoiceList(with: String) {
        voiceList = with
    }

    func setSpeakSpeed(to: Int) {
        speed = to
    }

    func setSpecifiedVoice(to: String) {
        specifiedVoice = to
    }

    func setRepeatAnswer(to: Bool) {
        repeatAnswer = to
    }

    // getter
    func getVoiceList() -> String {
        return voiceList
    }

    func getSpeackSpeed() -> Int {
        return speed
    }

    func getSpecifiedVoice() -> String {
        return specifiedVoice
    }

    func getRepeatAnswer() -> Bool {
        return repeatAnswer
    }

    func getError() -> String {
        return error
    }

    // explain the errors
    func explainError(withCode: Int) -> String {
        switch withCode {
        case 1:
            return "You need to setup to using the speak() function, the setup() function will looking for the voice list on your device so that you can choose a specified voice to speak"
        case 2:
            return "This happen when the program cannot find any voice that have installed on your devices, please check it"
        default:
            return "Unknow error code???"
        }
    }
}
