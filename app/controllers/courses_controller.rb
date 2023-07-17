class CoursesController < ApiController
  before_action :check_teacher, only: [:create, :show, :show_by_status_teacher, :update, :destroy, :show_by_name_teacher]
  before_action :check_student, only: [:show_by_name_cat_student, :show_by_cat_student, :show_avl_courses_student]

  def index
    if @current_user.type == "Teacher"
      teachers_course = @current_user.courses
      course_list(teachers_course)
    else
      all_courses = Course.where(status: "active")
      if all_courses.present?
        render json: all_courses, each_serializer: WithoutEnrollDataSerializer, status: :ok
      else
        render json: { errors: "Sorry Courses Not Available" }, status: :unprocessable_entity
      end
    end
  end

  def show
    teacher_course = @current_user.courses.find_by(id: params[:id])
    if teacher_course.present?
      render json: teacher_course, status: :ok
    else
      render json: { errors: "Sorry Course With id #{params[:id]} is Not Available In Your Course List" }
    end
  end

  def create
    course = @current_user.courses.new(course_params)
    if course.save
      render json: course, status: :ok
    else
      render json: { errors: course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    course_update = @current_user.courses.find_by(id: params[:id])
    if course_update.present?
      if course_update.update(course_params)
        render json: course_update, status: :ok
      else
        render json: { errors: "Unable to Update Course's Data" }, status: :unprocessable_entity
      end
    else
      render json: { message: "Course Record Not Found With id #{params[:id]}" }, status: :unprocessable_entity
    end
  end

  def destroy
    delete_course = @current_user.courses.find_by(id: params[:id])
    if delete_course.present?
      delete_course.destroy
      render json: { message: "Successfully Delete Course with id #{params[:id]}" }, status: :ok
    else
      render json: { message: "Course With Id #{params[:id]} Not Found In Your Courses List" }, status: :unprocessable_entity
    end
  end

  def show_by_name_teacher
    name_course = @current_user.courses.where("course_name LIKE ?", "%#{params[:course_name]}%")
    course_list(name_course)
  end

  def show_by_status_teacher
    status_course = @current_user.courses.where(status: params[:status])
    course_list(status_course)
  end

  def show_by_cat_student
    cat_course = Course.where(category_id: params[:category_id], status: "active")
    if cat_course.length != 0
      render json: cat_course, each_serializer: WithoutEnrollDataSerializer, status: :ok
    else
      render json: { errors: "Sorry Course With category id #{params[:category_id]} is Not Available In Your Course List" }, status: :unprocessable_entity
    end
  end

  def show_by_name_cat_student
    name_course = Course.where(status: "active", category_id: params[:category_id]).where("course_name LIKE ?", "%#{params[:course_name]}%")
    if name_course.length != 0
      render json: name_course, each_serializer: WithoutEnrollDataSerializer, status: :ok
    else
      render json: { errors: "Sorry Course With Name #{params[:course_name]} is Not Available In Your Course List" }, status: :unprocessable_entity
    end
  end

  def course_list(data)
    if data.present?
      render json: data, status: :ok
    else
      render json: { errors: "Courses Not Available" }, status: 404
    end
  end

  private

  def course_params
    params.permit(:course_name, :course_desc, :video, :category_id, :status)
  end
end
