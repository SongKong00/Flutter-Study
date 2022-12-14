import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';        //문자열 포맷팅 패키지
import 'package:fluttertoast/fluttertoast.dart';    //toast 메세지 패키지

enum TimerStatus { running, paused, stopped, resting }    //TimeStatus 자료형 설정

class TimerScreen extends StatefulWidget{
  const TimerScreen({super.key});

  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>{
  static const WORK_SECONDS = 25;  //*60
  static const REST_SECONDS = 5;   //*60
  late TimerStatus _timerStatus;
  late int _timer;
  late int _pomodoroCount;

  @override
  void initState(){       //상태 초기화
    super.initState();
    _timerStatus = TimerStatus.stopped;
    print(_timerStatus.toString());
    _timer = WORK_SECONDS;
    _pomodoroCount = 0;
  }

  String secondsToString(int seconds){
    return sprintf("%02d:%02d", [seconds ~/60, seconds % 60]);    //%02d : 정수 2자리 출력하는데 2자리보다 작으면 0으로 채우도록 함
  }

  void run(){
    setState(() {
      _timerStatus = TimerStatus.running;
      print("[=>] " + _timerStatus.toString());
      runTimer();
    });
  }

  void rest(){
    setState(() {
      _timer = REST_SECONDS;
      _timerStatus = TimerStatus.resting;
      print("[=>] " + _timerStatus.toString());
    });
  }

  void pause(){
    setState(() {
      _timerStatus =TimerStatus.paused;
      print("[=>] " + _timerStatus.toString());
    });
  }

  void resume(){
    run();
  }

  void stop(){
    setState(() {
      _timer = WORK_SECONDS;
      _timerStatus = TimerStatus.stopped;
      print("[=>] " + _timerStatus.toString());
    });
  }

  void showToast(String message){
    Fluttertoast.showToast(
        msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16
    );
  }

  void runTimer() async {
    Timer.periodic(Duration(seconds: 1), (Timer t) {      //1초마다 불러오는 함수
      switch (_timerStatus) {
        case TimerStatus.paused:
          t.cancel();
          break;
        case TimerStatus.stopped:
          t.cancel();
          break;
        case TimerStatus.running:
          if (_timer <= 0){         //시간 0초 되면 불러오는 경우
            showToast("작업 완료!");
            rest();
          }
          else {
            setState(() {
              _timer -= 1;          //시간 1초씩 줄어듬
            });
          }
          break;
        case TimerStatus.resting:
          if (_timer <= 0) {
            setState(() {
              _pomodoroCount += 1;
            });
            showToast("오늘 $_pomodoroCount개의 뽀모도로를 달성했습니다.");
            t.cancel();
            stop();
          }
          else{
            setState(() {
              _timer -= 1;
            });
          }
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context){
    final List<Widget> _runningButtons = [
      ElevatedButton(
          onPressed: _timerStatus == TimerStatus.paused ? resume : pause,           //일시 정지 중? 버튼 '계속하기', 안멈추면 버튼 '일시정지'로 뜨도록
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text(
            _timerStatus == TimerStatus.paused ? '계속하기' : '일시정지',
            style: TextStyle(color: Colors.white,fontSize: 16),
          ),
      ),
      const Padding(
          padding: EdgeInsets.all(20)
      ),
      ElevatedButton(
          onPressed: stop,
          style: ElevatedButton.styleFrom(primary: Colors.grey),
          child: const Text(
            '포기하기',
            style: TextStyle(fontSize: 16),
          ),
      ),
    ];
    final List<Widget> _stoppedButtons = [
      ElevatedButton(
          onPressed: run,
          style: ElevatedButton.styleFrom(
            primary: _timerStatus == TimerStatus.resting ? Colors.green : Colors.blue,
          ),
          child: const Text(
              '시작하기',
              style: TextStyle(color: Colors.white, fontSize: 16),
          ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('뽀모도로 타이머'),
        backgroundColor: _timerStatus == TimerStatus.resting ? Colors.green : Colors.blue,      //휴식시간에는 초록색 배경, 아니면 파란색 배경
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _timerStatus == TimerStatus.resting ? Colors.green : Colors.blue,          //휴식시간에는 초록색 배경, 작업 중에는 파란색 배경
            ),
            child: Center(
              child: Text(
                secondsToString(_timer),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _timerStatus == TimerStatus.resting          //휴식중? 버튼 있음 : 없음
          ? const []
              : _timerStatus == TimerStatus.stopped              //정지? 정지 중 버튼 : 작업 중 버튼
              ? _stoppedButtons
              : _runningButtons,
          )
        ],
      ),
    );
  }
}