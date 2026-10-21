#include "response_speed_select.h"

#include "esphome/core/log.h"
#include "esphome/core/version.h"

namespace esphome::ld2410s {

#if ESPHOME_VERSION_CODE >= VERSION_CODE(2026, 10, 0)
ESPHOME_LOG_TAG(TAG, "ld2410s.select");
#else
static const char *const TAG = "ld2410s.select";
#endif

void ResponseSpeedSelect::control(size_t index) {
  this->publish_state(index);
  this->parent_->set_response_speed(index);
}

}  // namespace esphome::ld2410s
