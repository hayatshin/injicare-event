import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/models/user_profile.dart';
import 'package:injicare_event/palette.dart';
import 'package:injicare_event/repos/event_repo.dart';
import 'package:injicare_event/utils.dart';
import 'package:injicare_event/view_models/event_view_model.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletons/skeletons.dart';

class EventDetailCountScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  final UserProfile userProfile;

  const EventDetailCountScreen({
    super.key,
    required this.eventModel,
    required this.userProfile,
  });

  @override
  ConsumerState<EventDetailCountScreen> createState() =>
      _EventDetailCountScreenState();
}

class _EventDetailCountScreenState
    extends ConsumerState<EventDetailCountScreen> {
  bool _myParticipationLoadingComplete = false;
  bool _myParticipation = false;

  bool _myApplyForGiftLoadingComplete = false;
  bool _myApplyForGift = false;
  // int _participatingAt = 0;
  // int _userStartSeconds = 0;
  // int _userEndSeconds = 0;
  EventModel stateEventModel = EventModel.empty();
  bool _completeScoreLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserScore();
    _initializeMyParticipation();
    _initializeMyApplyingForGift();
    // _initializeScore();
  }

  Future<void> _initializeUserScore() async {
    final updateScoreModel = await ref
        .read(eventProvider.notifier)
        .updateUserScore(widget.eventModel, widget.userProfile.userId);

    setState(() {
      _completeScoreLoading = true;
      stateEventModel = updateScoreModel;
    });
  }

  Future<void> _initializeMyParticipation() async {
    List<Map<String, dynamic>> dbMyParticipation = await ref
        .read(eventRepo)
        .checkMyParticiapationEvent(
            widget.eventModel.eventId, widget.userProfile.userId);

    if (mounted) {
      setState(() {
        _myParticipationLoadingComplete = true;
        _myParticipation = dbMyParticipation.isNotEmpty;
        // _participatingAt = dbMyParticipation.isNotEmpty
        //     ? dbMyParticipation[0]["createdAt"]
        //     : 0;
      });
    }
  }

  Future<void> _initializeMyApplyingForGift() async {
    bool myApplyForGift = await ref.read(eventRepo).userSubmitEventGiftOrNot(
        widget.userProfile.userId, widget.eventModel.eventId);

    if (mounted) {
      setState(() {
        _myApplyForGiftLoadingComplete = true;
        _myApplyForGift = myApplyForGift;
      });
    }
  }

  // Future<void> _initializeScore() async {
  //   int startSeconds =
  //       convertStartDateStringToSeconds(widget.eventModel.startDate);
  //   int userStartSeconds =
  //       _participatingAt > startSeconds ? _participatingAt : startSeconds;

  //   int endSeconds = convertEndDateStringToSeconds(widget.eventModel.endDate);
  //   setState(() {
  //     _userStartSeconds = userStartSeconds;
  //     _userEndSeconds = endSeconds;
  //   });
  // }

  Future<void> _showMyStatus(Size size, BuildContext rcontext) async {
    int userAge = widget.userProfile.userAge != null
        ? int.parse(widget.userProfile.userAge!)
        : 0;
    bool userAgeCheck = stateEventModel.ageLimit != null
        ? userAge >= stateEventModel.ageLimit!
        : true;

    if (!rcontext.mounted) return;
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor:
          isDarkMode(rcontext) ? Colors.grey.shade900 : Colors.white,
      elevation: 0,
      context: rcontext,
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(rcontext)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: SizedBox(
            width: size.width,
            height: size.height * 0.7,
            child: widget.eventModel.state == "종료"
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gaps.v20,
                      Container(
                        width: size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          "assets/jpg/girl_fail.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Gaps.v32,
                      const Text(
                        "행사가 이미 종료되었습니다.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Sizes.size24,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    ],
                  )
                : !userAgeCheck
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Gaps.v20,
                          Container(
                            width: size.height * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Sizes.size20,
                              ),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.asset(
                              "assets/jpg/girl_fail.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Gaps.v32,
                          const Text(
                            "참여하실 수 없는 연령입니다.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Sizes.size24,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Gaps.v20,
                          Container(
                            width: size.height * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Sizes.size20,
                              ),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.asset(
                              "assets/jpg/girl_success.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Gaps.v32,
                          const Text(
                            "행사에 참여하게 되었습니다!\n열심히 도전해보아요~~",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Sizes.size24,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        ],
                      ),
          ),
        );
      },
    );

    if (widget.eventModel.state == "진행") {
      final participantUpdateEventModel = stateEventModel.copyWith(
          participantsNumber: stateEventModel.participantsNumber != null
              ? stateEventModel.participantsNumber! + 1
              : 1);

      await ref.read(eventRepo).pariticipateEvent(
          widget.userProfile.userId, widget.eventModel.eventId);

      setState(() {
        stateEventModel = participantUpdateEventModel;
        _myParticipation = true;
      });
    }

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  Future<void> _getGift(Size size) async {
    final userGifts = await ref
        .read(eventRepo)
        .getEventUserNumbers(widget.eventModel.eventId);
    final achieverNumbers = stateEventModel.achieversNumber;
    bool canGetGift = userGifts < achieverNumbers;

    if (!mounted) return;
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor:
          isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
      elevation: 0,
      context: context,
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: SizedBox(
            width: size.width,
            height: size.height * 0.7,
            child: !canGetGift
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gaps.v20,
                      Container(
                        width: size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          "assets/jpg/girl_fail.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Gaps.v32,
                      const Text(
                        "선착순이 마감되었습니다.\n다음에 다시 도전해보아요!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Sizes.size24,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gaps.v20,
                      Container(
                        width: size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          "assets/jpg/girl_success.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Gaps.v32,
                      const Text(
                        "선물 신청이 완료되었습니다~!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Sizes.size24,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    ],
                  ),
          ),
        );
      },
    );

    if (canGetGift) {
      await ref.read(eventRepo).submitEventGift(
          widget.userProfile.userId, widget.eventModel.eventId);

      setState(() {
        _myApplyForGift = true;
      });
    }

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: Sizes.size20,
              color: isDarkMode(context) ? Colors.grey.shade400 : Colors.black,
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CachedNetworkImage(
                    imageUrl: widget.eventModel.eventImage,
                    fit: BoxFit.cover,
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child: Container(
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isDarkMode(context) ? Colors.black : Colors.white,
                        border: Border.all(
                          color:
                              isDarkMode(context) ? Colors.white : Colors.black,
                          width: 1,
                        ),
                      ),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isDarkMode(context) ? Colors.white : Colors.black,
                          BlendMode.srcIn,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/circle-chevron-left-thin.svg",
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.width * 0.2,
                  left: size.width * 0.1,
                  right: size.width * 0.1,
                  bottom: size.width * 0.1,
                  child: Column(
                    children: [
                      !_completeScoreLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                    width: 150,
                                    height: 30,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.blueGrey.shade800,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Sizes.size4,
                                      horizontal: Sizes.size10,
                                    ),
                                    child: Text(
                                      stateEventModel.state == "종료"
                                          ? "종료"
                                          : "${stateEventModel.leftDays}일 남음",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: Sizes.size18,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ),
                                Gaps.h10,
                                Text(
                                  "${stateEventModel.participantsNumber}명 참여",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: Sizes.size18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                      Gaps.v12,
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode(context)
                                ? Colors.grey.shade800
                                : Colors.white,
                            border: Border.all(
                              width: 2,
                              color: isDarkMode(context)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.size32,
                              horizontal: Sizes.size20,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.eventModel.eventImage,
                                      fit: BoxFit.cover,
                                      fadeInDuration: Duration.zero,
                                      fadeOutDuration: Duration.zero,
                                    ),
                                  ),
                                  Gaps.v20,
                                  !_myParticipationLoadingComplete
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: Sizes.size20,
                                          ),
                                          child: CircularProgressIndicator
                                              .adaptive(
                                            valueColor: AlwaysStoppedAnimation(
                                              isDarkMode(context)
                                                  ? Colors.grey.shade700
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                        )
                                      : _myParticipation
                                          ? !_completeScoreLoading
                                              ? Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SkeletonLine(
                                                          style:
                                                              SkeletonLineStyle(
                                                            width: size.width *
                                                                0.5,
                                                            height: 20,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  10),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Gaps.v32,
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SkeletonLine(
                                                          style:
                                                              SkeletonLineStyle(
                                                            width: size.width *
                                                                0.4,
                                                            height: 25,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  10),
                                                            ),
                                                          ),
                                                        ),
                                                        SkeletonLine(
                                                          style:
                                                              SkeletonLineStyle(
                                                            width: size.width *
                                                                0.2,
                                                            height: 25,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  10),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                )
                                              : Stack(
                                                  children: [
                                                    if (stateEventModel
                                                            .userAchieveOrNot ??
                                                        false)
                                                      LottieBuilder.asset(
                                                        "assets/anims/anim_fanfare.json",
                                                      ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: Palette()
                                                                    .iconPurple
                                                                    .withOpacity(
                                                                        0.6),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    "나의 행사 달성 상황",
                                                                    style:
                                                                        TextStyle(
                                                                      height:
                                                                          1.2,
                                                                      fontSize:
                                                                          Sizes
                                                                              .size20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w100,
                                                                      color: isDarkMode(
                                                                              context)
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                    ),
                                                                  ),
                                                                  Gaps.v20,
                                                                  // 달성 시
                                                                  if (stateEventModel
                                                                          .userAchieveOrNot ??
                                                                      false)
                                                                    Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            SizedBox(
                                                                              child: LottieBuilder.asset(
                                                                                "assets/anims/congratulation.json",
                                                                                width: 40,
                                                                              ),
                                                                            ),
                                                                            Gaps.h5,
                                                                            Text(
                                                                              "달성했습니다!",
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                fontSize: Sizes.size24,
                                                                                fontWeight: FontWeight.w800,
                                                                                color: isDarkMode(context) ? Palette().iconPurple : Palette().ocPurple,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Gaps.v20,
                                                                        Text(
                                                                          "아래 '누르고 선물 받기'\n버튼을 눌러서\n선물을 받아가세요~",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            height:
                                                                                1.2,
                                                                            color: isDarkMode(context)
                                                                                ? Palette().iconPurple
                                                                                : Palette().ocPurple,
                                                                          ),
                                                                        ),
                                                                        Gaps.v32,
                                                                      ],
                                                                    ),

                                                                  if (widget
                                                                          .eventModel
                                                                          .diaryCount >
                                                                      0)
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "❍  일기",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontSize:
                                                                                Sizes.size18,
                                                                          ),
                                                                        ),
                                                                        Gaps.v10,
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            MyProgressScreen(
                                                                              totalScore: stateEventModel.diaryCount,
                                                                              userScore: stateEventModel.userDiaryCount!,
                                                                            ),
                                                                            Flexible(
                                                                              child: Text(
                                                                                "${stateEventModel.userDiaryCount!}회 / ${stateEventModel.diaryCount}회",
                                                                                style: TextStyle(
                                                                                  color: isDarkMode(context) ? Colors.grey.shade500 : Colors.grey.shade600,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: Sizes.size18,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  Gaps.v10,
                                                                  if (widget
                                                                          .eventModel
                                                                          .quizCount >
                                                                      0)
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "❍  문제 풀기",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontSize:
                                                                                Sizes.size18,
                                                                          ),
                                                                        ),
                                                                        Gaps.v10,
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            MyProgressScreen(
                                                                              totalScore: stateEventModel.quizCount,
                                                                              userScore: stateEventModel.userQuizCount!,
                                                                            ),
                                                                            Flexible(
                                                                              child: Text(
                                                                                "${stateEventModel.userQuizCount!}회 / ${stateEventModel.quizCount}회",
                                                                                style: TextStyle(
                                                                                  color: isDarkMode(context) ? Colors.grey.shade500 : Colors.grey.shade600,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: Sizes.size18,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  Gaps.v10,
                                                                  if (widget
                                                                          .eventModel
                                                                          .commentCount >
                                                                      0)
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "❍  댓글",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontSize:
                                                                                Sizes.size18,
                                                                          ),
                                                                        ),
                                                                        Gaps.v10,
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            MyProgressScreen(
                                                                              totalScore: stateEventModel.commentCount,
                                                                              userScore: stateEventModel.userCommentCount!,
                                                                            ),
                                                                            Flexible(
                                                                              child: Text(
                                                                                "${stateEventModel.userCommentCount!}회 / ${stateEventModel.commentCount}회",
                                                                                style: TextStyle(
                                                                                  color: isDarkMode(context) ? Colors.grey.shade500 : Colors.grey.shade600,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: Sizes.size18,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  Gaps.v10,
                                                                  if (widget
                                                                          .eventModel
                                                                          .likeCount >
                                                                      0)
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "❍  좋아요",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontSize:
                                                                                Sizes.size18,
                                                                          ),
                                                                        ),
                                                                        Gaps.v10,
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            MyProgressScreen(
                                                                              totalScore: stateEventModel.likeCount,
                                                                              userScore: stateEventModel.userLikeCount!,
                                                                            ),
                                                                            Flexible(
                                                                              child: Text(
                                                                                "${stateEventModel.userLikeCount!}회 / ${stateEventModel.likeCount}회",
                                                                                style: TextStyle(
                                                                                  color: isDarkMode(context) ? Colors.grey.shade500 : Colors.grey.shade600,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: Sizes.size18,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  Gaps.v10,
                                                                  if (widget
                                                                          .eventModel
                                                                          .invitationCount >
                                                                      0)
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "❍  친구초대",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontSize:
                                                                                Sizes.size18,
                                                                          ),
                                                                        ),
                                                                        Gaps.v10,
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            MyProgressScreen(
                                                                              totalScore: stateEventModel.invitationCount,
                                                                              userScore: stateEventModel.userInvitationCount!,
                                                                            ),
                                                                            Flexible(
                                                                              child: Text(
                                                                                "${stateEventModel.userInvitationCount}회 / ${widget.eventModel.invitationCount}회",
                                                                                style: TextStyle(
                                                                                  color: isDarkMode(context) ? Colors.grey.shade500 : Colors.grey.shade600,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: Sizes.size18,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                          : UserPointLoadingWidget(
                                              size: size,
                                              eventModel: widget.eventModel,
                                            ),
                                  Gaps.v24,
                                  Text(
                                    widget.eventModel.title,
                                    softWrap: true,
                                    style: const TextStyle(
                                      height: 1.2,
                                      fontSize: Sizes.size24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Gaps.v24,
                                  Text(
                                    widget.eventModel.description,
                                    style: const TextStyle(
                                      height: 1.3,
                                      fontSize: Sizes.size20,
                                    ),
                                  ),
                                  const DividerWidget(),
                                  FutureBuilder(
                                    future: ref
                                        .read(eventRepo)
                                        .convertContractRegionIdToName(widget
                                                .eventModel.contractRegionId ??
                                            ""),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return EventInfoTile(
                                            header: "주최 기관",
                                            info: snapshot.data == "-"
                                                ? "인지케어"
                                                : "${snapshot.data}");
                                      } else if (snapshot.hasError) {
                                        // ignore: avoid_print
                                        print("name: ${snapshot.error}");
                                      }
                                      return Container();
                                    },
                                  ),
                                  Gaps.v10,
                                  EventInfoTile(
                                      header: "행사 진행일",
                                      info:
                                          "${widget.eventModel.startDate} ~ ${widget.eventModel.endDate}"),
                                  Gaps.v10,
                                  EventInfoTile(
                                      header: "진행 상황",
                                      info: "${widget.eventModel.state}"),
                                  Gaps.v10,
                                  EventInfoTile(
                                      header: "달성 인원",
                                      info: widget.eventModel.achieversNumber !=
                                              0
                                          ? "${widget.eventModel.achieversNumber}명"
                                          : "제한 없음"),
                                  Gaps.v10,
                                  EventInfoTile(
                                      header: "연령 제한",
                                      info: widget.eventModel.ageLimit != 0
                                          ? "${widget.eventModel.ageLimit}세 이상"
                                          : "제한 없음"),
                                  const DividerWidget(),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "🥇🥈 점수 계산 방법",
                                            style: TextStyle(
                                              fontSize: Sizes.size20,
                                              fontWeight: FontWeight.w800,
                                              color: isDarkMode(context)
                                                  ? Colors.white
                                                  : Colors.black,
                                              height: 1.3,
                                            ),
                                          ),
                                          Gaps.v20,
                                          if (widget
                                                  .eventModel.invitationCount >
                                              0)
                                            CountTile(
                                                header: "친구초대",
                                                point: widget.eventModel
                                                    .invitationCount),
                                          if (widget.eventModel.diaryCount > 0)
                                            CountTile(
                                                header: "일기",
                                                point: widget
                                                    .eventModel.diaryCount),
                                          if (widget.eventModel.quizCount > 0)
                                            Column(
                                              children: [
                                                CountTile(
                                                    header: "문제 풀기",
                                                    point: widget
                                                        .eventModel.quizCount),
                                                Text(
                                                  "   (하루 최대 1회)",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size16,
                                                    fontWeight: FontWeight.w100,
                                                    color: isDarkMode(context)
                                                        ? Colors.grey.shade600
                                                        : Colors.grey.shade500,
                                                  ),
                                                ),
                                                Gaps.v4,
                                              ],
                                            ),
                                          if (widget.eventModel.commentCount >
                                              0)
                                            CountTile(
                                                header: "댓글",
                                                point: widget
                                                    .eventModel.commentCount),
                                          if (widget.eventModel.likeCount > 0)
                                            CountTile(
                                                header: "좋아요",
                                                point:
                                                    widget.eventModel.likeCount)
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Gaps.v24,
                      !_myParticipationLoadingComplete ||
                              !_myApplyForGiftLoadingComplete ||
                              !_completeScoreLoading
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                        height: 55,
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : !stateEventModel.userAchieveOrNot!
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GestureDetector(
                                    onTap: _myParticipation
                                        ? null
                                        : () async =>
                                            await _showMyStatus(size, context),
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: _myParticipation
                                            ? Colors.grey.shade500
                                            : Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size5,
                                        ),
                                        border: Border.all(
                                          color: isDarkMode(context)
                                              ? Colors.white
                                              : Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _myParticipation ? "참여 중" : "참여하기",
                                          style: TextStyle(
                                            fontSize: Sizes.size20,
                                            color: isDarkMode(context)
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GestureDetector(
                                    onTap: _myApplyForGift
                                        ? null
                                        : () async => await _getGift(size),
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: _myApplyForGift
                                            ? Colors.grey.shade500
                                            : Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size5,
                                        ),
                                        border: Border.all(
                                          color: isDarkMode(context)
                                              ? Colors.white
                                              : Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                      child: _myApplyForGift
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "선물 신청 완료!",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size20,
                                                    color: isDarkMode(context)
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "누르고",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size20,
                                                    color: isDarkMode(context)
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Gaps.h10,
                                                Image.asset(
                                                  "assets/jpg/gift.png",
                                                  width: 40,
                                                ),
                                                Gaps.h10,
                                                Text(
                                                  "받기",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size20,
                                                    color: isDarkMode(context)
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingProgressScreen extends StatefulWidget {
  const LoadingProgressScreen({super.key});

  @override
  State<LoadingProgressScreen> createState() => _LoadingProgressScreenState();
}

class _LoadingProgressScreenState extends State<LoadingProgressScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  );

  late Animation<double> _progress = Tween(
    begin: 0.000,
    end: 1.0,
  ).animate(_curve);

  Future<void> _setProgressValues() async {
    // int targetPoint = widget.eventModel.targetScore;

    if (mounted) {
      setState(() {
        _progress = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(_curve);
      });
    }

    _animationController.repeat(
      reverse: true,
    );
  }

  @override
  void initState() {
    super.initState();

    _setProgressValues();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return CustomPaint(
              painter: MyProgressPainter(
                  progress: _progress.value, context: context),
              size: Size(size.width, size.width * 0.12),
            );
          },
        ),
      ],
    );
  }
}

class MyProgressScreen extends ConsumerStatefulWidget {
  // final EventModel eventModel;
  final int totalScore;
  final int userScore;
  const MyProgressScreen({
    super.key,
    // required this.eventModel,
    required this.totalScore,
    required this.userScore,
  });

  @override
  ConsumerState<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends ConsumerState<MyProgressScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..forward();

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  );

  late Animation<double> _progress = Tween(
    begin: 0.005,
    end: 1.0,
  ).animate(_curve);

  Future<void> _setProgressValues() async {
    // int targetPoint = widget.eventModel.targetScore;

    if (mounted) {
      setState(() {
        _progress = Tween(
          begin: 0.0,
          end: (widget.userScore / widget.totalScore) < 1
              ? (widget.userScore / widget.totalScore)
              : 1.0,
        ).animate(_curve);
      });
    }

    _animationController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();

    _setProgressValues();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return CustomPaint(
              painter: MyProgressPainter(
                  progress: _progress.value, context: context),
              size: Size(size.width * 0.4, 20),
            );
          },
        ),
      ],
    );
  }
}

class MyProgressPainter extends CustomPainter {
  final BuildContext context;
  final double progress;

  MyProgressPainter({
    required this.context,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // final radius = size.width / 5;
    // const startingAngle = -0.5 * pi;

    // circle
    final backCirclePaint = Paint()
      ..color = Theme.of(context).primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = 20;

    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, 20), const Radius.circular(20));
    canvas.drawRRect(rrect, backCirclePaint);

    final redArcPaint = Paint()
      ..color = Theme.of(context).primaryColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;

    // progress
    // final progressArcRect = Rect.fromCircle(
    //   center: center,
    //   radius: radius,
    // );
    // canvas.drawArc(
    //     progressArcRect, startingAngle, progress * pi, false, redArcPaint);

    final redRrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * progress, 20),
        const Radius.circular(20));
    canvas.drawRRect(redRrect, redArcPaint);
  }

  @override
  bool shouldRepaint(covariant MyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class UserPointLoadingWidget extends StatefulWidget {
  final Size size;
  final EventModel eventModel;
  const UserPointLoadingWidget({
    super.key,
    required this.size,
    required this.eventModel,
  });

  @override
  State<UserPointLoadingWidget> createState() => _UserPointLoadingWidgetState();
}

class _UserPointLoadingWidgetState extends State<UserPointLoadingWidget> {
  // bool _completeLoading = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        completeLoading.value = true;
      }
    });
  }

  final completeLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "행사 기준 내 점수",
          style: TextStyle(
            height: 1.2,
            fontSize: Sizes.size20,
            fontWeight: FontWeight.w100,
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
        ),
        Text(
          "→ 참여 후 계산됩니다!",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        Gaps.v20,
        const LoadingProgressScreen(),
        // ValueListenableBuilder(
        //   valueListenable: completeLoading,
        //   builder: (context, value, child) {
        //     if (value) {
        //       return MyProgressScreen(
        //         eventModel: widget.eventModel,
        //         userScore: 0,
        //       );
        //     }
        //   },
        // ),
      ],
    );
  }
}

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.v32,
        Container(
          height: 1,
          decoration: BoxDecoration(
            color: isDarkMode(context)
                ? Colors.grey.shade700
                : Colors.grey.shade400,
          ),
        ),
        Gaps.v24,
      ],
    );
  }
}

class EventInfoTile extends StatelessWidget {
  final String header;
  final String info;
  const EventInfoTile({
    super.key,
    required this.header,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: RichText(
            softWrap: true,
            text: TextSpan(
              text: "❍ $header:  ",
              style: TextStyle(
                  fontSize: Sizes.size20,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: isDarkMode(context) ? Colors.white : Colors.black),
              children: [
                TextSpan(
                  text: info,
                  style: const TextStyle(
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CountTile extends StatelessWidget {
  final String header;
  final int point;
  const CountTile({
    super.key,
    required this.header,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: "- $header  →  ",
            style: TextStyle(
              fontSize: Sizes.size20,
              fontWeight: FontWeight.w100,
              color: isDarkMode(context) ? Colors.white : Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                text: "$point회",
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Gaps.v5,
      ],
    );
  }
}
