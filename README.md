# SwiftWeatherApp_CombineAndTaskGroup
This is an improved Weather App where we can fetch for the weather for a specific city, add it to favorites, then fetch a list for the weather in every city at favorites.  

Fetching the weather for all cities is done with two approaches: using task groups (introduced in iOS 13) and using Combine. This demo focuses mostly on the `WeatherService` class.

In order to use combine/task groups please use the switch or modify the code accordingly.  
Please change `static let appID =XXXXX` where XXXXX is your own appID obtained from Open Weather API.

Demo Images:  

<img width="200" alt="Screenshot 2024-05-28 at 23 40 47" src="https://github.com/Andrei0795/SwiftWeatherApp_CombineAndTaskGroup/assets/10764238/f284c038-6b23-4c46-9d21-736a8265b1d1">
<img width="200" alt="Screenshot 2024-05-28 at 23 40 47" src="https://github.com/Andrei0795/SwiftWeatherApp_CombineAndTaskGroup/assets/10764238/e5740cd1-1fc4-4564-b604-a6b2c3ad0cb3">
<img width="200" alt="Screenshot 2024-05-28 at 23 40 47" src="https://github.com/Andrei0795/SwiftWeatherApp_CombineAndTaskGroup/assets/10764238/73b7178c-f4b9-442e-9470-10a288314708">
