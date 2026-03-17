// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '幸运轮盘';

  @override
  String get participants => '参与者';

  @override
  String get roulette => '轮盘';

  @override
  String get history => '历史记录';

  @override
  String get enterParticipantName => '输入参与者姓名';

  @override
  String get exampleName => '例：张三';

  @override
  String get noParticipants => '🙋‍♀️ 请添加参与者！';

  @override
  String get winner => '中奖人数';

  @override
  String get spinRoulette => '开始旋转';

  @override
  String get finalWinner => '最终中奖者';

  @override
  String get noHistory => '📭 暂无中奖记录。';

  @override
  String get times => ' 次';

  @override
  String get resetHistory => '重置历史';

  @override
  String get confirmResetHistory => '确定要重置所有历史记录吗？';

  @override
  String get cancel => '取消';

  @override
  String get reset => '重置';

  @override
  String get personUnit => '人';

  @override
  String get clearAll => '全部清除';

  @override
  String findingWinner(int current, int total) {
    return '正在从 $total 人中选取第 $current 位中奖者...';
  }

  @override
  String selectingWinners(int count) {
    return '按顺序选取 $count 位中奖者';
  }

  @override
  String get winnerTitle => '中奖！';

  @override
  String get winnersTitle => '中奖名单！';

  @override
  String get close => '关闭';

  @override
  String get spinAgain => '再次旋转';

  @override
  String get presets => '预设';

  @override
  String get savePreset => '保存当前列表';

  @override
  String get noPresets => '📂 没有已保存的预设。';

  @override
  String get presetNameHint => '输入预设名称';

  @override
  String get save => '保存';

  @override
  String get loadPreset => '加载';

  @override
  String get deletePreset => '删除';

  @override
  String get confirmDeletePreset => '确定要删除此预设吗？';

  @override
  String get presetLoaded => '预设已加载。';

  @override
  String get presetSaved => '预设已保存。';

  @override
  String get presetNameEmpty => '请输入名称。';

  @override
  String presetPersonCount(int count) {
    return '$count人';
  }

  @override
  String get removeAds => '移除广告';

  @override
  String get restorePurchase => '恢复购买';

  @override
  String get proVersion => 'PRO版本';
}
