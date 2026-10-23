#include "distance_reporting_freq_number.h"

#include "esphome/core/log.h"
#include "esphome/core/version.h"

namespace esphome::ld2410s {

#if ESPHOME_VERSION_CODE >= VERSION_CODE(2026, 10, 0)
ESPHOME_LOG_TAG(TAG, "ld2410s.number");
#else
static const char *const TAG = "ld2410s.number";
#endif

void DistReportingFreqNumber::control(float value) {
  this->publish_state(value);
  this->parent_->set_distance_reporting_freq(value);
}

}  // namespace esphome::ld2410s
