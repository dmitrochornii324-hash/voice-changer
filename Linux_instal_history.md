# Voice Changer (w-okada) — інструкція для Linux

Коротка інструкція з установки, запуску, аудіо-маршрутизації та зупинки  
[w-okada/voice-changer](https://github.com/w-okada/voice-changer) на Ubuntu (Predator PHN16 тощо).

Перевірено на: Python 3.10 (Miniconda), PipeWire, NVIDIA-ноутбук.  
**Telegram** (Web/Desktop) з віртуальним mic працює. **Signal** voice messages — зазвичай ні.

---

## Зупинити все і прибрати віртуальні мікрофони

```bash
# 1) Зупинити Voice Changer
pkill -f MMVCServerSIO.py || true
fuser -k 18888/tcp || true

# 2) Прибрати VC_Out / VC_Mic (усі модулі з цими іменами)
pactl list short modules | awk '/sink_name=VC_Out|source_name=VC_Mic/{print $1}' | xargs -r -n1 pactl unload-module

# 3) Повернути звичайний мікрофон за замовчуванням (приклад — вбудований Mic1)
#    Спочатку подивіться список:
pactl list short sources
#    Потім поставте свій реальний source, наприклад:
# pactl set-default-source alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source

# 4) Перевірка: VC-пристроїв бути не повинно
pactl list short sinks | grep VC_ || echo "VC sinks: none"
pactl list short sources | grep VC_ || echo "VC sources: none"
```

Деактивувати conda-env (лише вихід з shell-оточення):

```bash
conda deactivate
```

Самі файли проєкту й Miniconda **не видаляються** командами вище — лише процес і віртуальні audio-пристрої.

### Повне видалення проєкту (опційно)

```bash
pkill -f MMVCServerSIO.py || true
rm -rf ~/voice-changer
# Miniconda env:
conda env remove -n vcclient-dev
# усю Miniconda (якщо більше не потрібна):
# rm -rf ~/miniconda3
```

---

## Вимоги

- Ubuntu / Debian-подібна система з PipeWire або PulseAudio
- Miniconda з Python **3.10** (системний Python 3.14 не підходить)
- `libportaudio2`, компілятор для частини пакетів
- Chrome для UI
- Для ігор/месенджерів — віртуальний mic `VC_Mic`

---

## Одноразове встановлення

### 1. Системні пакети

```bash
sudo apt-get update
sudo apt-get install -y git libportaudio2 libasound2-dev build-essential python3-dev pavucontrol patchelf
```

### 2. Miniconda + env Python 3.10

```bash
cd ~
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/miniconda3"
source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda init bash
# новий термінал або: source ~/.bashrc

conda create -y -n vcclient-dev python=3.10
conda activate vcclient-dev
```

### 3. Клон репозиторію

```bash
cd ~
git clone https://github.com/w-okada/voice-changer.git
cd ~/voice-changer/server
```

### 4. Залежності Python

Новий `pip` ламає старий `omegaconf` для `fairseq` — спочатку понизьте pip:

```bash
conda activate vcclient-dev
cd ~/voice-changer/server

pip install "pip<24.1"
pip install "setuptools<81"

# NVIDIA CUDA 11.8 wheels (якщо є NVIDIA)
pip install torch==2.0.1 torchaudio==2.0.2 --index-url https://download.pytorch.org/whl/cu118

pip install -r requirements.txt

# обов’язкові пакети, яких часто немає в requirements
pip install fairseq==0.12.2
pip install pyworld==0.3.4
# якщо pyworld не збирається:
# pip install pyworld==0.3.4 --no-build-isolation
```

### 5. Фікс onnxruntime на новому glibc (Ubuntu з glibc ≥ 2.41)

Помилка виглядає так: `cannot enable executable stack as shared object requires`.

```bash
conda activate vcclient-dev
find "$CONDA_PREFIX/lib/python3.10/site-packages/onnxruntime" -name '*.so' -exec patchelf --clear-execstack {} \;
python -c "import onnxruntime as ort; print(ort.__version__, ort.get_available_providers())"
```

Після `pip install --force-reinstall onnxruntime-gpu=...` фікс треба повторити.

### 6. Перевірка імпортів

```bash
python -c "from fairseq import checkpoint_utils; import pyworld, torch; print('ok', torch.__version__, torch.cuda.is_available())"
```

---

## Щоденний запуск

### A. Віртуальний кабель (для Telegram тощо)

Збережіть скрипт:

```bash
cat > ~/vc-audio.sh << 'EOF'
#!/bin/bash
pactl list short modules | awk '/sink_name=VC_Out|source_name=VC_Mic/{print $1}' | xargs -r -n1 pactl unload-module

pactl load-module module-null-sink \
  sink_name=VC_Out \
  sink_properties=device.description=VC_Out

pactl load-module module-remap-source \
  master=VC_Out.monitor \
  source_name=VC_Mic \
  source_properties=device.description=VC_Mic

pactl set-default-source VC_Mic
echo "Default Source: $(pactl info | awk -F': ' '/Default Source/{print $2}')"
pactl list short sources | grep VC_
EOF
chmod +x ~/vc-audio.sh
```

Запуск:

```bash
~/vc-audio.sh
```

Після ребуту модулі зникають — знову `~/vc-audio.sh`.

### B. Сервер Voice Changer

```bash
source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate vcclient-dev

pkill -f MMVCServerSIO.py || true
fuser -k 18888/tcp || true

cd ~/voice-changer/server
python MMVCServerSIO.py -p 18888 --https false
```

Відкрийте Chrome: [http://localhost:18888/](http://localhost:18888/)

### C. Налаштування в UI

| Поле | Значення |
| --- | --- |
| Модель | будь-який RVC-слот (або свій upload) |
| AUDIO | **server** → reload (надійніше для PipeWire) |
| input | ваш реальний mic (AirPods / Mic1), **не** `VC_Mic` і бажано не `Default` |
| output | **VC_Out** |
| monitor | ваші навушники (щоб чути себе) |
| GPU | `cpu` або CUDA GPU, якщо `torch.cuda.is_available()` |
| F0 Det. | `rmvpe_onnx` (стабільно; `dio`/`harvest` потребують pyworld) |
| кнопка | **start** |

Перевірка: `vol` росте, коли говорите; у monitor чути змінений голос.

### D. Месенджер

**Telegram Desktop / Web (працює):**

- Microphone = **VC_Mic** (або Default, якщо `pactl set-default-source VC_Mic` уже зроблено)
- У Chrome для Web: дозвіл мікрофона сайту → саме `VC_Mic`

**Signal (зазвичай не працює для voice messages):**

- У Calls може бути видно `VC_Mic`, але голосові повідомлення часто пишуть справжній mic
- Обхід: `pavucontrol` → Recording під час запису → примусово `VC_Mic` (незручно і ненадійно)
- Для VC краще Telegram / Discord

---

## Типові помилки

| Симптом | Що робити |
| --- | --- |
| `python3.10: not found` | Ставити Miniconda + `conda create -n vcclient-dev python=3.10` |
| `No module named 'torch'` | Залежності ставились не в conda-env |
| `onnxruntime` + executable stack | `patchelf --clear-execstack` на `.so` |
| `No module named 'pkg_resources'` | `pip install "setuptools<81"` |
| `fairseq` / omegaconf conflict | `pip install "pip<24.1"` потім `fairseq==0.12.2` |
| `No module named 'pyworld'` | `pip install pyworld==0.3.4` |
| `Address already in use` | `pkill -f MMVCServerSIO.py`; `fuser -k 18888/tcp` |
| Чуєте змінений голос, у чаті — свій | Месенджер пише реальний mic → поставте **VC_Mic**, VC output = **VC_Out** |
| `vol: 0` | input = `none` / не натиснуто start / mute в системі |
| `Can't initialize NVML` | Проблема драйвера NVIDIA; можна працювати на CPU |

Лог запуску:

```bash
python MMVCServerSIO.py -p 18888 --https false 2>&1 | tee ~/vc-crash.log
```

---

## Схема аудіо

```text
Мікрофон (AirPods / Mic1)
        ↓
 Voice Changer (RVC)
        ↓
     VC_Out  ──monitor──→ навушники (ви чуєте змінений голос)
        ↓
  VC_Mic (= VC_Out.monitor)
        ↓
 Telegram / Discord (як Microphone)
```

---

## Корисні посилання

- Репозиторій: https://github.com/w-okada/voice-changer
- Prefab-білди (Windows/Mac): https://huggingface.co/wok000/vcclient000/tree/main
- Dev guide: https://github.com/w-okada/voice-changer/blob/master/README_dev_en.md
