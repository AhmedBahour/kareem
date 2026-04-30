import '../../data/models/exercise_model.dart';

class SeedData {
  static List<ExerciseModel> exercises() {
    return const [
      ExerciseModel(
        id: 'arm-lift-001',
        title: 'رفع الذراعين الهادئ',
        subtitle: 'حركة علاجية للكتف وتحسين المدى الحركي',
        category: 'الكتف والذراع',
        level: 'مبتدئ',
        durationMinutes: 6,
        focusArea: 'تخفيف تيبس الكتف',
        description:
            'تمرين خفيف يرفع الذراعين للأمام ولأعلى بشكل متدرج بدون تحميل زائد على المفصل.',
        instructions: [
          'قف أو اجلس بظهر مستقيم.',
          'ارفع الذراعين ببطء حتى مستوى الكتف.',
          'توقف نصف ثانية ثم أنزل الذراعين بهدوء.',
          'تنفس بهدوء ولا ترفع الكتفين نحو الأذن.',
        ],
        wellnessNote: 'إذا شعرت بألم حاد أوقف التمرين مباشرة وخفف زاوية الرفع.',
        targetAccuracy: 78,
        jointTargets: [
          JointTarget(
            name: 'left_shoulder_raise',
            points: ['leftHip', 'leftShoulder', 'leftElbow'],
            minAngle: 38,
            maxAngle: 118,
            weight: 0.35,
          ),
          JointTarget(
            name: 'right_shoulder_raise',
            points: ['rightHip', 'rightShoulder', 'rightElbow'],
            minAngle: 38,
            maxAngle: 118,
            weight: 0.35,
          ),
          JointTarget(
            name: 'left_elbow_soft',
            points: ['leftShoulder', 'leftElbow', 'leftWrist'],
            minAngle: 145,
            maxAngle: 185,
            weight: 0.15,
          ),
          JointTarget(
            name: 'right_elbow_soft',
            points: ['rightShoulder', 'rightElbow', 'rightWrist'],
            minAngle: 145,
            maxAngle: 185,
            weight: 0.15,
          ),
        ],
      ),
      ExerciseModel(
        id: 'side-stretch-002',
        title: 'إطالة جانبية خفيفة',
        subtitle: 'فتح الجذع والضلوع بدون ضغط',
        category: 'الإطالات',
        level: 'مبتدئ',
        durationMinutes: 5,
        focusArea: 'مرونة الجذع والتنفس',
        description:
            'إطالة بسيطة لفتح جانبي الجذع وتحسين الراحة أثناء التنفس والحركة اليومية.',
        instructions: [
          'ارفع الذراع اليمنى فوق الرأس.',
          'ميل الجذع بلطف للجهة المقابلة.',
          'حافظ على الحوض ثابتًا.',
          'كرر للجهة الثانية بهدوء.',
        ],
        wellnessNote: 'هذا التمرين مناسب قبل النوم أو بعد الجلوس الطويل.',
        targetAccuracy: 74,
        jointTargets: [
          JointTarget(
            name: 'left_side_extension',
            points: ['leftElbow', 'leftShoulder', 'leftHip'],
            minAngle: 130,
            maxAngle: 180,
            weight: 0.5,
          ),
          JointTarget(
            name: 'right_side_extension',
            points: ['rightElbow', 'rightShoulder', 'rightHip'],
            minAngle: 130,
            maxAngle: 180,
            weight: 0.5,
          ),
        ],
      ),
      ExerciseModel(
        id: 'elbow-flex-003',
        title: 'ثني ومد الذراع',
        subtitle: 'تقوية خفيفة بدون أوزان',
        category: 'الكوع والساعد',
        level: 'مبتدئ',
        durationMinutes: 7,
        focusArea: 'تحسين التحكم بالمرفق والساعد',
        description:
            'حركة منزلية هادئة تشبه تمارين الإحماء لكنها مصممة للعلاج الطبيعي الخفيف.',
        instructions: [
          'ثبت العضد بمحاذاة الجسم.',
          'اثن المرفق حتى تصبح اليد قريبة من الكتف.',
          'أعد الذراع ببطء لوضع البداية.',
          'لا تستخدم سرعة زائدة أثناء الصعود أو النزول.',
        ],
        wellnessNote: 'ركز على البطء المنتظم أكثر من عدد التكرارات.',
        targetAccuracy: 80,
        jointTargets: [
          JointTarget(
            name: 'left_elbow_flex',
            points: ['leftShoulder', 'leftElbow', 'leftWrist'],
            minAngle: 45,
            maxAngle: 128,
            weight: 0.5,
          ),
          JointTarget(
            name: 'right_elbow_flex',
            points: ['rightShoulder', 'rightElbow', 'rightWrist'],
            minAngle: 45,
            maxAngle: 128,
            weight: 0.5,
          ),
        ],
      ),
      ExerciseModel(
        id: 'warmup-open-004',
        title: 'فتح الصدر وتدوير الكتفين',
        subtitle: 'تسخين علاجي لطيف قبل الجلسة',
        category: 'الإحماء',
        level: 'مبتدئ',
        durationMinutes: 4,
        focusArea: 'تنشيط أعلى الجسم',
        description:
            'تهيئة لطيفة للكتفين والصدر قبل التمارين الأساسية، مناسبة للمساحات المنزلية الصغيرة.',
        instructions: [
          'لف الكتفين للخلف ببطء.',
          'افتح الذراعين جانبًا بدون شد قوي.',
          'أبق الرقبة مرتاحة والتنفس مستقرًا.',
          'كرر بنمط مريح ومنتظم.',
        ],
        wellnessNote: 'ابدأ بهذا التمرين لو كان الجسم متيبسًا في الصباح.',
        targetAccuracy: 72,
        jointTargets: [
          JointTarget(
            name: 'left_open_chest',
            points: ['leftElbow', 'leftShoulder', 'leftHip'],
            minAngle: 65,
            maxAngle: 150,
            weight: 0.5,
          ),
          JointTarget(
            name: 'right_open_chest',
            points: ['rightElbow', 'rightShoulder', 'rightHip'],
            minAngle: 65,
            maxAngle: 150,
            weight: 0.5,
          ),
        ],
      ),
    ];
  }
}
