import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import 'entry_media_platform.dart';
import 'entry_media_service.dart';
import 'entry_media_validator.dart';

export 'entry_media_service.dart';

typedef AnnoyanceMediaService = EntryMediaService;

class DefaultAnnoyanceMediaService extends DefaultEntryMediaService {
  DefaultAnnoyanceMediaService({
    ImagePicker? imagePicker,
    AudioRecorder? audioRecorder,
    EntryMediaPlatform? platform,
    EntryMediaValidator validator = const EntryMediaValidator(),
  }) : super(
         recordingFilePrefix: 'annoyance',
         imagePicker: imagePicker,
         audioRecorder: audioRecorder,
         platform: platform,
         validator: validator,
       );
}
